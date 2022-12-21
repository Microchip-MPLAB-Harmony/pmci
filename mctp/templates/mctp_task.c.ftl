<#--
/*******************************************************************************
  MCTP Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   mctp_task.c.ftl

  Summary:
    MCTP Freemarker Template File

  Description:

*******************************************************************************/
-->
/*****************************************************************************
 * Copyright (c) 2020 Microchip Technology Inc. and its subsidiaries.
 * You may use this software and any derivatives exclusively with
 * Microchip products.
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".
 * NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE,
 * INCLUDING ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY,
 * AND FITNESS FOR A PARTICULAR PURPOSE, OR ITS INTERACTION WITH MICROCHIP
 * PRODUCTS, COMBINATION WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
 * INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
 * WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
 * BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.
 * TO THE FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL
 * CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF
 * FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 * MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE
 * OF THESE TERMS.
 *****************************************************************************/

#include "definitions.h"

#include "mctp.h"
#include "mctp_common.h"
#include "mctp_task.h"
#include "mctp_smbus.h"
#include "mctp_config.h"

/* MPU */
static void mctp_main(void *pvParameters);
MCTP_BSS_ATTR static StaticTask_t mctp_task1_tcb;
MCTP_BSS_ATTR static uint32_t mctp_task1_stack[MCTP_TASK1_STACK_WORD_SIZE] MCTP_TASK1_STACK_ALIGN;
MCTP_BSS_ATTR static TaskHandle_t mctp_task1_handle = NULL;
MCTP_BSS_ATTR static MCTP_CONTEXT *mctpContext = NULL;

static union
{
    uint32_t w[MCTP_TASK1_BUF_SIZE / 4];
    uint8_t  b[MCTP_TASK1_BUF_SIZE];
} mctp_task1_buf MCTP_BSS_ATTR MCTP_TASK1_BUF_ALIGN;

#define MCTP_TASK1_BUF_ADDR &mctp_task1_buf.w[0]

TaskHandle_t mctp_task1_get_handle(void)
{
    return mctp_task1_handle;
}

/****************************************************************/
/** mctp_task_create()
* Function to Create the freertos task for mctp
* @param  pvParams
* @return none
**********************************************************************/
int mctp_app_task_create(void *pvParams)
{
<#if (MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || MCTP_IS_RTOS_COMPONENT_CONNECTED == false>
    /* Create the task without using any dynamic memory allocation. */
    mctp_task1_handle = xTaskCreateStatic(
                            mctp_main,                  /* Function that implements the task. */
                            "mctp_task",                /* Text name for the task. */
                            MCTP_TASK1_STACK_WORD_SIZE, /* Number of indexes in the xStack array. */
                            ( void * ) NULL,            /* Parameter passed into the task. */
                            MCTP_TASK1_PRIORITY,        /* Priority at which the task is created. */
                            mctp_task1_stack,           /* Array to use as the task's stack. */
                            &mctp_task1_tcb );          /* Variable to hold the task's data structure. */
    
    if (mctp_task1_handle == NULL)
    {
        return -1;
    }
<#else>
    BaseType_t xReturned;
    /* Create the task, storing the handle. */
    xReturned = xTaskCreate(
                    mctp_main,                          /* Function that implements the task. */
                    "mctp_task",                        /* Text name for the task. */
                    MCTP_TASK1_STACK_WORD_SIZE,         /* Stack size in words, not bytes. */
                    ( void * ) NULL,                    /* Parameter passed into the task. */
                    MCTP_TASK1_PRIORITY,                /* Priority at which the task is created. */
                    &mctp_task1_handle );               /* Used to pass out the created task's handle. */

    if( xReturned == pdFAIL )
    {
        /* The task was created.  Use the task's handle to delete the task. */
        return -1;
    }
</#if>
    mctpContext = mctp_ctxt_get();
<#if (MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || MCTP_IS_RTOS_COMPONENT_CONNECTED == false>
    mctpContext->xmctp_EventGroupHandle = xEventGroupCreateStatic(&mctpContext->xmctp_CreatedEventGroup);
<#else>
    mctpContext->xmctp_EventGroupHandle = xEventGroupCreate();
</#if>
    return 0;
}

/******************************************************************************/
/** mctp_ctxt_get()
* Get the MCTP Context
* @param void
* @return MCTP_context
*******************************************************************************/
MCTP_CONTEXT* mctp_ctxt_get(void)
{
    MCTP_CONTEXT* ret_mctp_ctxt;

// coverity[misra_c_2012_rule_11_3_violation:FALSE]
    ret_mctp_ctxt = (MCTP_CONTEXT*)(MCTP_TASK1_BUF_ADDR);

    return ret_mctp_ctxt;
}

/******************************************************************************/
/** mctp_main()
* main process of MCTP task
* @param  pvParameters - Pointer that will be used as the parameter for the task
* being created.
* @return none
********************************************************************************/
static void mctp_main(void* pvParameters)
{
    EventBits_t uxBits;
    mctpContext = mctp_ctxt_get();

    if(NULL == mctpContext)
    {
        return;
    }

	mctp_init_task();
    mctp_update_eid(MCTP_EC_EID);
	mctp_i2c_update(HOST_SLAVE_ADDR, (uint8_t)MCTP_I2C_CLK_FREQ);
	mctp_smbaddress_update(mctpContext->i2c_slave_addr, MCTP_I2C_PORT);
	mctp_update_i2c_params(mctpContext);
	sb_mctp_enable();

    while(true)
    {
        uxBits = xEventGroupWaitBits((mctpContext->xmctp_EventGroupHandle),
                                     (MCTP_EVENT_BIT | MCTP_I2C_ENABLE_BIT | MCTP_EVENT_BIT),
                                     pdTRUE,
                                     pdFALSE,
                                     portMAX_DELAY);

        if(MCTP_I2C_ENABLE_BIT == (uxBits & MCTP_I2C_ENABLE_BIT))
        {
            (void)mctp_smbus_init();
        }

        if(MCTP_EVENT_BIT == (uxBits & MCTP_EVENT_BIT))
        {
            mctp_event_task();
        }
    }
}

/****************************************************************/
/** SET_MCTP_EVENT_FLAG()
* Set event flag to trigger MCTP task to process
* @param  none
* @return none
**********************************************************************/
void SET_MCTP_EVENT_FLAG(void)
{
    mctpContext = mctp_ctxt_get();
    if(NULL == mctpContext)
    {
        return;
    }
    (void)xEventGroupSetBits( mctpContext->xmctp_EventGroupHandle, MCTP_EVENT_BIT );
}

void mctp_i2c_update(uint8_t slv_addr, uint8_t freq)
{
    mctpContext = mctp_ctxt_get();
    if(NULL == mctpContext)
    {
        return;
    }
    mctpContext->i2c_bus_freq = freq;
    mctpContext->i2c_slave_addr = slv_addr;
}

void mctp_update_eid(uint8_t eid)
{
    mctpContext = mctp_ctxt_get();
    if(NULL == mctpContext)
    {
        return;
    }
    mctpContext->eid = eid;
}

void sb_mctp_enable(void)
{
    mctpContext = mctp_ctxt_get();
    if(NULL == mctpContext)
    {
        return;
    }
    (void)xEventGroupSetBits( mctpContext->xmctp_EventGroupHandle, MCTP_I2C_ENABLE_BIT );
}