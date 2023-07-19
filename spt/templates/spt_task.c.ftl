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

#include "spt_task.h"
#include "spt_app.h"

/* MPU */
static void spt_main(void *pvParameters);
SPT_BSS_ATTR static StaticTask_t spt_task1_tcb;
SPT_BSS_ATTR static uint32_t spt_task1_stack[SPT_TASK1_STACK_WORD_SIZE] SPT_TASK1_STACK_ALIGN;
SPT_BSS_ATTR static TaskHandle_t spt_task1_handle = NULL;
SPT_BSS_ATTR static SPT_CONTEXT *sptContext = NULL;

static union
{
    uint32_t w[SPT_TASK1_BUF_SIZE / 4];
    uint8_t  b[SPT_TASK1_BUF_SIZE];
} spt_task1_buf SPT_BSS_ATTR SPT_TASK1_BUF_ALIGN;

#define SPT_TASK1_BUF_ADDR &spt_task1_buf.w[0]

<#if (MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || MCTP_IS_RTOS_COMPONENT_CONNECTED == false>
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

static const TaskParameters_t spt_task1_def =
{
    .pcName = "spt_main",
    .pxTaskBuffer = &spt_task1_tcb
};
 </#if>
 
/****************************************************************/
/** spt_task1_get_handle
* Get the SPT task handle
* @param  void
* @return TaskHandle_t - SPT task handle
*****************************************************************/
TaskHandle_t spt_task_get_handle(void)
{
    return spt_task1_handle;
}

/****************************************************************/
/** spt_app_task_create()
* Function to Create the freertos task for spt
* @param  pvParams
* @return none
*****************************************************************/
int spt_app_task_create(void *pvParams)
{
<#if (MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || MCTP_IS_RTOS_COMPONENT_CONNECTED == false>
    /* Create the task without using any dynamic memory allocation. */
    spt_task1_handle = xTaskCreateStatic(
                            spt_main,                  /* Function that implements the task. */
                            "spt_task",                /* Text name for the task. */
                            SPT_TASK1_STACK_WORD_SIZE, /* Number of indexes in the xStack array. */
                            ( void * ) NULL,            /* Parameter passed into the task. */
                            SPT_TASK1_PRIORITY,        /* Priority at which the task is created. */
                            spt_task1_stack,           /* Array to use as the task's stack. */
                            &spt_task1_tcb );          /* Variable to hold the task's data structure. */
    
    if (spt_task1_handle == NULL)
    {
        return -1;
    }
<#else>
    BaseType_t xReturned;
    /* Create the task, storing the handle. */
    xReturned = xTaskCreate(
                    spt_main,                          /* Function that implements the task. */
                    "spt_task",                        /* Text name for the task. */
                    SPT_TASK1_STACK_WORD_SIZE,         /* Stack size in words, not bytes. */
                    ( void * ) NULL,                    /* Parameter passed into the task. */
                    configSPT_TASK1_PRIORITY,                /* Priority at which the task is created. */
                    &spt_task1_handle );               /* Used to pass out the created task's handle. */

    if( xReturned == pdFAIL )
    {
        /* The task was created.  Use the task's handle to delete the task. */
        return -1;
    }
</#if>
    sptContext = spt_ctxt_get();
<#if (MCTP_IS_RTOS_COMPONENT_CONNECTED == true && FreeRTOS.FREERTOS_STATIC_ALLOC == true) || MCTP_IS_RTOS_COMPONENT_CONNECTED == false>
    sptContext->xspt_EventGroupHandle = xEventGroupCreateStatic(&sptContext->xspt_CreatedEventGroup);
<#else>
    sptContext->xspt_EventGroupHandle = xEventGroupCreate();
</#if>
    return 0;
}

/****************************************************************/
/** spt_ctxt_get()
* Get the SPT Context
* @param void
* @return SPT_context
*****************************************************************/
SPT_CONTEXT* spt_ctxt_get(void)
{
    SPT_CONTEXT* ret_spt_ctxt;

// coverity[misra_c_2012_rule_11_3_violation:FALSE]
    ret_spt_ctxt = (SPT_CONTEXT*)(SPT_TASK1_BUF_ADDR);

    return ret_spt_ctxt;
}

SPT_CONTEXT_PER_CHANNEL* spt_channel_ctxt_get(uint8_t channel)
{
    SPT_CONTEXT* ret_spt_ctxt = spt_ctxt_get();
    SPT_CONTEXT_PER_CHANNEL* ch_txt = NULL;
    if(NULL != ret_spt_ctxt)
    {
        if(channel)
        {
            ch_txt = &ret_spt_ctxt->sptCtxt1;
        }
        else
        {
            ch_txt = &ret_spt_ctxt->sptCtxt0;
        }
    }

    return ch_txt;
}

/****************************************************************/
/** spt_main()
* main process of SPT task
* @param  pvParameters - Pointer that will be used as the parameter for the task
* being created.
* @return none
*****************************************************************/
static void spt_main(void* pvParameters)
{
    EventBits_t uxBits;
    sptContext = spt_ctxt_get();

    if(NULL == sptContext)
    {
        return;
    }

    while(true)
    {
        uxBits = xEventGroupWaitBits((sptContext->xspt_EventGroupHandle),
                                     0xFF,
                                     pdTRUE,
                                     pdFALSE,
                                     portMAX_DELAY);
        if(uxBits)
        {
            spt_event_handle(uxBits);
        }
    }
}

void spt_set_event_bits(EventBits_t uxBitsToSet)
{
    sptContext = spt_ctxt_get();
    if(NULL == sptContext)
    {
        return;
    }
    (void)xEventGroupSetBits( sptContext->xspt_EventGroupHandle, uxBitsToSet );
}

void spt_set_event_bits_isr(EventBits_t uxBitsToSet)
{
    sptContext = spt_ctxt_get();
    if(NULL == sptContext)
    {
        return;
    }
    
    BaseType_t xHigherPriorityTaskWoken_spt, xResult;
    
    xHigherPriorityTaskWoken_spt = pdFALSE;
    
    xResult = xEventGroupSetBitsFromISR(sptContext->xspt_EventGroupHandle, uxBitsToSet,
                                        &xHigherPriorityTaskWoken_spt);
    if (xResult != pdFAIL)
    {
        portEND_SWITCHING_ISR(xHigherPriorityTaskWoken_spt);
    }
}