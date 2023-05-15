<#--
/*******************************************************************************
  PLDM Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   pldm_task.c.ftl

  Summary:
    PLDM Freemarker Template File

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
#include "pldm_task.h"
#include "pldm_pkt_prcs.h"
#include "pldm_common.h"

/* MPU */
static void pldm_main(void *pvParameters);
static StaticTask_t pldm_tcb;

PLDM_BSS0_ATTR static uint32_t pldm_stack[PLDM_STACK_WORD_SIZE] PLDM_STACK_ALIGN;
PLDM_BSS2_ATTR static TaskHandle_t pldm_handle;
PLDM_BSS2_ATTR PLDM_CONTEXT *pldmContext;

union
{
    uint32_t w[PLDM_TASK_BUF_SIZE / 4];
    uint8_t  b[PLDM_TASK_BUF_SIZE];
} pldm_task_buf PLDM_BSS0_ATTR PLDM_TASK_BUF_ALIGN;

#define PLDM_TASK_BUF_ADDR &pldm_task_buf.w[0]
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
/*
 * FreeRTOS TaskParameters_t structure contains two constant items:
 * type * const objname.
 * The C standard states these items are immutable and can only be
 * set at initialization not run time assignment.
 * Therefore we must create a TaskParameters_t as a static global to
 * initialize the pcName and pxTaskBuffer objects.
 * We can intialize all other items in the task creation function.
 */
TaskHandle_t pldm_get_handle(void)
{
    return pldm_handle;
}

/****************************************************************/
/** pldm_app_task_create()
* Function to Create the freertos task for pldm
* @param  pvParams
* @return none
**********************************************************************/
int pldm_app_task_create(void *pvParams)
{
<#if (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == false)>
    /* Create the task without using any dynamic memory allocation. */
    pldm_handle = xTaskCreateStatic(
                            pldm_main,                  /* Function that implements the task. */
                            "pldm_task",                /* Text name for the task. */
                            PLDM_STACK_WORD_SIZE, /* Number of indexes in the xStack array. */
                            ( void * ) 1,               /* Parameter passed into the task. */
                            PLDM_PRIORITY,        /* Priority at which the task is created. */
                            pldm_stack,           /* Array to use as the task's stack. */
                            &pldm_tcb );          /* Variable to hold the task's data structure. */
    
    if (pldm_handle == NULL)
    {
        return -1;
    }
<#else>
    BaseType_t xReturned;
    /* Create the task, storing the handle. */
    xReturned = xTaskCreate(
                    pldm_main,                          /* Function that implements the task. */
                    "pldm_task",                        /* Text name for the task. */
                    PLDM_STACK_WORD_SIZE,         /* Stack size in words, not bytes. */
                    ( void * ) 1,                       /* Parameter passed into the task. */
                    PLDM_PRIORITY,                /* Priority at which the task is created. */
                    &pldm_handle );               /* Used to pass out the created task's handle. */

    if( xReturned == pdFAIL )
    {
        /* The task was created.  Use the task's handle to delete the task. */
        return -1;
    }
</#if>
    pldmContext = pldm_ctxt_get();
<#if (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == false)>
    pldmContext->xPLDMEventGroupHandle = xEventGroupCreateStatic(&pldmContext->xPLDMCreatedEventGroup);
<#else>
    pldmContext->xPLDMEventGroupHandle = xEventGroupCreate();
</#if> 
    return 0;
}

/******************************************************************************/
/** pldm_ctxt_get()
* Get the PLDM Context
* @param void
* @return PLDM_context
*******************************************************************************/
PLDM_CONTEXT* pldm_ctxt_get(void)
{
    PLDM_CONTEXT* ret_pldm_ctxt;

    ret_pldm_ctxt = (PLDM_CONTEXT*)(PLDM_TASK_BUF_ADDR);

    return ret_pldm_ctxt;
}

/******************************************************************************/
/** pldm_main()
* main process of PLDM task
* @param  pvParameters - Pointer that will be used as the parameter for the task
* being created.
* @return none
********************************************************************************/
static void pldm_main(void* pvParameters)
{
    EventBits_t uxBits;

    pldmContext = pldm_ctxt_get();
    if(NULL == pldmContext)
    {
        return;
    }
<#if (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || (MCTP.MCTP_IS_RTOS_COMPONENT_CONNECTED == false)>    
    pldmContext->xPLDMRespTimer =
        xTimerCreateStatic("PLDMResp_timer", // Text name for the task.  Helps debugging only.  Not used by FreeRTOS.
                           pdMS_TO_TICKS(FD_T1), // The period of the timer in ticks.
                           pdTRUE, // This is an auto-reload timer.
                           NULL, // A variable incremented by the software timer's callback function.
                           PLDMResp_timer_callback, // The function to execute when the timer expires.
                           &pldmContext->PLDMResp_TimerBuffer); // The buffer that will hold the software timer structure.
<#else>
    pldmContext->xPLDMRespTimer =
        xTimerCreate("PLDMResp_timer", // Text name for the task.  Helps debugging only.  Not used by FreeRTOS.
                           pdMS_TO_TICKS(FD_T1), // The period of the timer in ticks.
                           pdTRUE, // This is an auto-reload timer.
                           NULL, // A variable incremented by the software timer's callback function.
                           PLDMResp_timer_callback); // The function to execute when the timer expires.                         
</#if>

    pldm_init_task(pldmContext);
    while(1)
    {
        uxBits = xEventGroupWaitBits(pldmContext->xPLDMEventGroupHandle,
                                     (PLDM_EVENT_BIT | PLDM_RESP_EVENT_BIT),
                                     pdTRUE,
                                     pdFALSE,
                                     portMAX_DELAY );
        if (PLDM_EVENT_BIT == (uxBits & PLDM_EVENT_BIT))
        {
            switch(pldmContext->pldm_state_info)
            {
            case PLDM_IDLE:
                // do nothing
                break;
            case PLDM_CMD_GET_AP_CFG:
                //pldm_pkt_get_config_from_apcfg(spdmContext);
                break;
            case PLDM_CMD_PROCESS_MODE:
                pldm1_event_task();
                break;
            }
        }
      
        if (PLDM_RESP_EVENT_BIT == (uxBits & PLDM_RESP_EVENT_BIT))
        {
            pldm_pkt_tx_packet();
        }
    }
}

/****************************************************************/
/** SET_PLDM_EVENT_FLAG()
* Set event flag to trigger PLDM task to process
* @param  none
* @return none
**********************************************************************/
void SET_PLDM_EVENT_FLAG(void)
{
    pldmContext = pldm_ctxt_get();
    if (NULL == pldmContext)
    {
        return;
    }
    pldmContext->pldm_state_info = PLDM_CMD_PROCESS_MODE;
    //pldmContext->pldm_tx_state = PLDM_TX_IDLE;
    xEventGroupSetBits( pldmContext->xPLDMEventGroupHandle, PLDM_EVENT_BIT);
}

/******************************************************************************/
/** pldm_response_timeout_start
* Start the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_response_timeout_start(void)
{
    pldmContext = pldm_ctxt_get();
    if (NULL != pldmContext)
    {
        if (NULL != pldmContext->xPLDMRespTimer)
        {
            if (xTimerStart(pldmContext->xPLDMRespTimer, 0) != pdPASS)
            {
                return;
            }
        }
    }
}

/******************************************************************************/
/** pldm_response_timeout_stop
* Stop the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_response_timeout_stop(void)
{
    pldmContext = pldm_ctxt_get();
    if (NULL != pldmContext)
    {
        if (NULL != pldmContext->xPLDMRespTimer)
        {
            if (xTimerStop(pldmContext->xPLDMRespTimer, 0) != pdPASS)
            {
                return;
            }
        }
    }
}

/******************************************************************************/
/** pldm_response_timeout_stop
* Stop the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_init_task(PLDM_CONTEXT *pldmContext)
{
    pldm_init_flags();
    pldm_pkt_init_config_params();
}