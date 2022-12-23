<#--
/*******************************************************************************
  SPDM Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   spdm_task.c.ftl

  Summary:
    SPDM Freemarker Template File

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

#include "spdm_task.h"
#include "spdm_pkt_prcs.h"
#include "spdm_common.h"

/* MPU */
static void spdm_main(void *pvParameters);
static StaticTask_t spdm_tcb;

SPDM_BSS0_ATTR static uint32_t spdm_stack[SPDM_STACK_WORD_SIZE] SPDM_STACK_ALIGN;
SPDM_BSS2_ATTR static TaskHandle_t spdm_handle;
SPDM_BSS2_ATTR SPDM_CONTEXT *spdmContext;

union
{
    uint32_t w[SPDM_TASK_BUF_SIZE / 4];
    uint8_t  b[SPDM_TASK_BUF_SIZE];
} spdm_task_buf SPDM_BSS0_ATTR SPDM_TASK_BUF_ALIGN;

#define SPDM_TASK_BUF_ADDR &spdm_task_buf.w[0]
/*
 * FreeRTOS restricted task creation requires TaskParameter_t
 * ISSUE: FreeRTOS defined member .pcName as const signed char * const
 * We get a compiler error assigning pcName at runtime.
 * If we assign statically then we can't use pvParams in the task
 * create function.
 * FreeRTOS MPU region attribute defines
 * portMPU_REGION_READ_WRITE
 * portMPU_REGION_PRIVILEGED_READ_ONLY
 * portMPU_REGION_READ_ONLY
 * portMPU_REGION_PRIVILEGED_READ_WRITE
 * portMPU_REGION_CACHEABLE_BUFFERABLE
 * portMPU_REGION_EXECUTE_NEVER
 */
TaskHandle_t spdm_get_handle(void)
{
    return spdm_handle;
}

/****************************************************************/
/** spdm_task_create()
* Function to Create the freertos task for spdm
* @param  pvParams
* @return none
**********************************************************************/
int spdm_app_task_create(void *pvParams)
{     
<#if (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == false)>
    /* Create the task without using any dynamic memory allocation. */
    spdm_handle = xTaskCreateStatic(
                            spdm_main,                  /* Function that implements the task. */
                            "spdm_task",                /* Text name for the task. */
                            SPDM_STACK_WORD_SIZE, /* Number of indexes in the xStack array. */
                            ( void * ) 1,               /* Parameter passed into the task. */
                            SPDM_PRIORITY,        /* Priority at which the task is created. */
                            spdm_stack,           /* Array to use as the task's stack. */
                            &spdm_tcb );          /* Variable to hold the task's data structure. */
    
    if (spdm_handle == NULL)
    {
        return -1;
    }
<#else>
    BaseType_t xReturned;
    /* Create the task, storing the handle. */
    xReturned = xTaskCreate(
                    spdm_main,                          /* Function that implements the task. */
                    "spdm_task",                        /* Text name for the task. */
                    SPDM_STACK_WORD_SIZE,         /* Stack size in words, not bytes. */
                    ( void * ) 1,                       /* Parameter passed into the task. */
                    SPDM_PRIORITY,                /* Priority at which the task is created. */
                    &spdm_handle );               /* Used to pass out the created task's handle. */

    if( xReturned == pdFAIL )
    {
        /* The task was created.  Use the task's handle to delete the task. */
        return -1;
    }
</#if>
    spdmContext = spdm_ctxt_get();
<#if (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == false)>
    spdmContext->xSPDMEventGroupHandle = xEventGroupCreateStatic(&spdmContext->xSPDMCreatedEventGroup);
<#else>
    spdmContext->xSPDMEventGroupHandle = xEventGroupCreate();
</#if> 
    return 0;
}

/******************************************************************************/
/** spdm_ctxt_get()
* Get the SPDM Context
* @param void
* @return SPDM_context
*******************************************************************************/
SPDM_CONTEXT* spdm_ctxt_get(void)
{
    SPDM_CONTEXT* ret_spdm_ctxt;

    ret_spdm_ctxt = (SPDM_CONTEXT*)(SPDM_TASK_BUF_ADDR);

    return ret_spdm_ctxt;
}

/******************************************************************************/
/** spdm_main()
* main process of SPDM task
* @param  pvParameters - Pointer that will be used as the parameter for the task
* being created.
* @return none
********************************************************************************/
static void spdm_main(void* pvParameters)
{
    EventBits_t uxBits;

    spdmContext = spdm_ctxt_get();
    if(NULL == spdmContext)
    {
        return;
    }

    spdmContext->spdm_state_info = SPDM_IDLE;
    trace1(0, SPDM_TSK, 0, "[%s]: SPDM tsk main proc", __FUNCTION__);
    spdm_init_task(spdmContext);
    while(1)
    {
        trace0(0, SPDM_TSK, 0, "spdm_main: Loop");
        uxBits = xEventGroupWaitBits(spdmContext->xSPDMEventGroupHandle,
                                     (SPDM_EVENT_BIT),
                                     pdTRUE,
                                     pdFALSE,
                                     portMAX_DELAY );

        //This check ensures SPDM requests are not executed when write certificate is being processed
        if ((SPDM_EVENT_BIT == (uxBits & SPDM_EVENT_BIT)) && (SPDM_I2C_EVENT_BIT != (uxBits & SPDM_I2C_EVENT_BIT)))
        {
            switch (spdmContext->spdm_state_info)
            {
            case SPDM_IDLE:
                spdm_event_task(spdmContext);
                //do nothing
                break;
            case SPDM_INIT_CERT_PARAMS:
                spdm_pkt_initialize_cert_params_to_default(spdmContext);
                break;
            case SPDM_GET_CERT_FROM_APCFG:
                spdm_pkt_get_cert_from_apcfg(spdmContext);
                break;
            case SPDM_COPY_CERT_DATA_TO_BUF:
                spdm_pkt_copy_cert_data_to_buf(spdmContext);
                break;
            case SPDM_CALC_HASH_CHAIN:
                spdm_pkt_store_hash_of_chain(spdmContext);
                break;
            case SPDM_CMD_PROCESS_MODE:
                spdm_event_task(spdmContext);
                break;
            default:
                break;
            }
        }
    }
}

/****************************************************************/
/** SET_SPDM_EVENT_FLAG()
* Set event flag to trigger SPDM task to process
* @param  none
* @return none
**********************************************************************/
void SET_SPDM_EVENT_FLAG(void)
{
    spdmContext = spdm_ctxt_get();
    if(NULL == spdmContext)
    {
        return;
    }
    trace1(0, SPDM_TSK, 0, "[%s]: set SPDM event", __FUNCTION__);
    xEventGroupSetBits( spdmContext->xSPDMEventGroupHandle, SPDM_EVENT_BIT );
}