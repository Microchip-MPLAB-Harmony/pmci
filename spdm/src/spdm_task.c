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
#include "spdm_task.h"
// #include "smbus/smb.h"
// #include "../mctp/mctp_data_iso.h"
// #include "../secure_boot/sb_core/sb_core_data_iso.h"
// #include "../secure_boot/sb_i2c/i2c_data_iso.h"
// #include "spdm_data_iso.h"
// #include "pldm_pkt_prcs.h"
#include "spdm_pkt_prcs.h"
#include "spdm_common.h"

/* MPU */
static void spdm_main(void *pvParameters);
static StaticTask_t spdm_tcb;

// extern SPDM_BSS1_ATTR DI_CONTEXT_SPDM *spdm_di_context;
SPDM_BSS0_ATTR static uint32_t spdm_stack[SPDM_STACK_WORD_SIZE] SPDM_STACK_ALIGN;
SPDM_BSS2_ATTR TaskHandle_t spdm_handle = NULL;
SPDM_BSS2_ATTR SPDM_CONTEXT *spdmContext = NULL;

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
/*
 * FreeRTOS TaskParameters_t structure contains two constant items:
 * type * const objname.
 * The C standard states these items are immutable and can only be
 * set at initialization not run time assignment.
 * Therefore we must create a TaskParameters_t as a static global to
 * initialize the pcName and pxTaskBuffer objects.
 * We can intialize all other items in the task creation function.
 */
// static const TaskParameters_t spdm_def =
// {
//     .pcName = "spdm_main",
//     .pxTaskBuffer = &spdm_tcb
// };

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
#ifdef config_CEC_AHB_PROTECTION_ENABLE
int spdm_app_task_create(void *pvParams, CEC_AHB_PRIV_REGS_VALUES *pTaskPrivRegValues)
#else
int spdm_app_task_create(void *pvParams)
#endif
{
//     trace1(0, SPDM_TSK, 0, "[%s]: SPDM task create - MPU", __FUNCTION__);
//     BaseType_t frc = pdFAIL;
//     uintptr_t spdm_bss0_addr = spdm_bss0_base();
//     size_t spdm_bss0_sz = spdm_bss0_size();
//     uintptr_t spdm_bss1_addr = spdm_bss1_base();
//     size_t spdm_bss1_sz = spdm_bss1_size();
//     uintptr_t spdm_bss2_addr = spdm_bss2_base();
//     size_t spdm_bss2_sz = spdm_bss2_size();

//     DI_CONTEXT_SPDM *di_context;

//     if ((spdm_bss0_addr == 0U) || (spdm_bss1_addr == 0U))
//     {
//         return -1;
//     }

//     // TaskParameters_t td = spdm_def;

//     td.pvTaskCode = spdm_main;
//     td.usStackDepth = SPDM_STACK_WORD_SIZE,
//     td.pvParameters = pvParams;
// #if (config_CEC_DATA_ISOLATION_CHECKS == 1)
//     td.uxPriority = SPDM_PRIORITY;
// #else
//     td.uxPriority = (SPDM_PRIORITY | portPRIVILEGE_BIT);
// #endif
//     td.puxStackBuffer = spdm_stack;
// #ifdef config_CEC_AHB_PROTECTION_ENABLE
//     td.pCecPrivRegValues = pTaskPrivRegValues;
// #endif

//     configASSERT(IS_PWR2(spdm_bss0_sz) != 0);
//     configASSERT((spdm_bss0_addr & (spdm_bss0_sz - 1U)) == 0U);

//     td.xRegions[0].pvBaseAddress = (void *)spdm_bss0_addr;
//     td.xRegions[0].ulLengthInBytes = spdm_bss0_sz;
//     td.xRegions[0].ulParameters = spdm_data_mpu_attr();

//     configASSERT(IS_PWR2(spdm_bss1_sz) != 0);
//     configASSERT((spdm_bss1_addr & (spdm_bss1_sz - 1U)) == 0U);

//     td.xRegions[1].pvBaseAddress = (void *)spdm_bss1_addr;
//     td.xRegions[1].ulLengthInBytes = spdm_bss1_sz;
//     td.xRegions[1].ulParameters = spdm_data_mpu_attr();

//     configASSERT(IS_PWR2(spdm_bss2_sz) != 0);
//     configASSERT((spdm_bss2_addr & (spdm_bss2_sz - 1U)) == 0U);

//     td.xRegions[2].pvBaseAddress = (void *)spdm_bss2_addr;
//     td.xRegions[2].ulLengthInBytes = spdm_bss2_sz;
//     td.xRegions[2].ulParameters = spdm_data_mpu_attr();

//     frc = xTaskCreateRestrictedStatic(&td, &spdm_handle);


//     if (frc != pdPASS)
//     {
//         return -1;
//     }

// #if config_CEC_DATA_ISOLATION_CHECKS == 1
//     di_checks_register_task(spdm_handle, DI_APP_ID_SPDM);
// #endif

//     /* Create other FreeRTOS objects required by this task here */
//     spdmContext =  spdm_ctxt_get();
// //    spdmContext->xSPDMEventGroupHandle = xEventGroupCreateStatic(&spdmContext->xSPDMCreatedEventGroup);
//     // di_context = (DI_CONTEXT_SPDM*)pvParams;
//     // sowmi check for event grp creation
//     // spdmContext->xSPDMEventGroupHandle = di_context->spdm_request.evt_grp_handle;

//     trace1(0, SPDM_TSK, 0, "[%s]: SPDM tsk create - Done", __FUNCTION__);

//     return 0;
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

    while(1)
    // {
        trace0(0, SPDM_TSK, 0, "spdm_main: Loop");
    //     uxBits = xEventGroupWaitBits(spdmContext->xSPDMEventGroupHandle,
    //                                  (SPDM_EVENT_BIT | PLDM_EVENT_BIT | MCTP_DI_EVENT_RESPONSE | SB_CORE_DI_EVENT_RESPONSE | SPDM_POST_AUTH_DONE_BIT |
    //                                   SPDM_I2C_EVENT_BIT | SB_CORE_DI_EVENT_APPLY_RESPONSE | PLDM_RESP_EVENT_BIT),
    //                                  pdTRUE,
    //                                  pdFALSE,
    //                                  portMAX_DELAY );
    //     if (SPDM_POST_AUTH_DONE_BIT == (uxBits & SPDM_POST_AUTH_DONE_BIT))
    //     {
    //         spdm_init_task(spdmContext);
    //     }
    //     if (SPDM_I2C_EVENT_BIT == (uxBits & SPDM_I2C_EVENT_BIT))
    //     {
    //         spdm_di_get_i2c_response();
    //     }
    //     //This check ensures SPDM requests are not executed when write certificate is being processed
    //     if ((SPDM_EVENT_BIT == (uxBits & SPDM_EVENT_BIT)) && (SPDM_I2C_EVENT_BIT != (uxBits & SPDM_I2C_EVENT_BIT)))
    //     {
    //         switch (spdmContext->spdm_state_info)
    //         {
    //         case SPDM_IDLE:
    //             spdm_event_task(spdmContext);
    //             //do nothing
    //             break;
    //         case SPDM_INIT_CERT_PARAMS:
    //             spdm_pkt_initialize_cert_params_to_default(spdmContext);
    //             break;
    //         case SPDM_GET_CERT_FROM_APCFG:
    //             spdm_pkt_get_cert_from_apcfg(spdmContext);
    //             break;
    //         case SPDM_COPY_CERT_DATA_TO_BUF:
    //             spdm_pkt_copy_cert_data_to_buf(spdmContext);
    //             break;
    //         case SPDM_CALC_HASH_CHAIN:
    //             spdm_pkt_store_hash_of_chain(spdmContext);
    //             break;
    //         case SPDM_CMD_PROCESS_MODE:
    //             spdm_event_task(spdmContext);
    //             break;
    //         default:
    //             break;
    //         }
    //     }
    //     if (MCTP_DI_EVENT_RESPONSE == (uxBits & MCTP_DI_EVENT_RESPONSE))
    //     {
    //         spdm_di_get_mctp_response();
    //     }
    //     if (SB_CORE_DI_EVENT_RESPONSE == (uxBits & SB_CORE_DI_EVENT_RESPONSE))
    //     {
    //         spdm_di_get_sb_core_response();
    //     }
    //     if (PLDM_EVENT_BIT == (uxBits & PLDM_EVENT_BIT))
    //     {
    //         trace0(0, SPDM_TSK, 0, "PLDM:bit set step into event task for recv and trans");
    //         switch(spdmContext->pldm_state_info)
    //         {
    //         case PLDM_IDLE:
    //             // do nothing
    //             break;
    //         case PLDM_CMD_GET_AP_CFG:
    //             //pldm_pkt_get_config_from_apcfg(spdmContext);
    //             break;
    //         case PLDM_CMD_PROCESS_MODE:
    //             break;
    //         }
    //     }
    //     if (SB_CORE_DI_EVENT_APPLY_RESPONSE == (uxBits & SB_CORE_DI_EVENT_APPLY_RESPONSE))
    //     {
    //         spdm_di_get_sb_core_response();
    //     }

    //     if (PLDM_RESP_EVENT_BIT == (uxBits & PLDM_RESP_EVENT_BIT))
    //     {
    //     }
    // }
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

// sowmi check in mctp header file

/****************************************************************/
/** SET_PLDM_EVENT_FLAG()
* Set event flag to trigger PLDM task to process
* @param  none
* @return none
**********************************************************************/
void SET_PLDM_EVENT_FLAG(void)
{
    spdmContext = spdm_ctxt_get();
    if (NULL == spdmContext)
    {
        return;
    }
    spdmContext->pldm_state_info = PLDM_CMD_PROCESS_MODE;
    //spdmContext->pldm_tx_state = PLDM_TX_IDLE;
    trace0(0, SPDM_TSK, 0, "PLDM:set event");
    xEventGroupSetBits( spdmContext->xSPDMEventGroupHandle, PLDM_EVENT_BIT);
}

/****************************************************************/
/** mctp_task_create()
* Function to Create the MCTP task for smbus
* @param  pvParams
* @return none
**********************************************************************/
#ifdef config_CEC_AHB_PROTECTION_ENABLE
int spdm_task_create(void *pvParams, CEC_AHB_PRIV_REGS_VALUES *pTaskPrivRegValues)
#else
int spdm_task_create(void *pvParams)
#endif
{
    void *di_ctxt;
    int return_val =0u;

    // di_ctxt = di_spdm_context_get();

#ifdef config_CEC_AHB_PROTECTION_ENABLE
    return_val = spdm_app_task_create(di_ctxt, pTaskPrivRegValues);
#else
    return_val = spdm_app_task_create(di_ctxt);
#endif

    return 0;
}

/******************************************************************************/
/** pldm_response_timeout_start
* Start the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_response_timeout_start(void)
{
    spdmContext = spdm_ctxt_get();
    if (NULL != spdmContext)
    {
        if (NULL != spdmContext->xPLDMRespTimer)
        {
            if (xTimerStart(spdmContext->xPLDMRespTimer, 0) != pdPASS)
            {
                trace0(1, SPDM_TSK, 1, "Err:PLDMResp tmr could not set to active state");
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
    spdmContext = spdm_ctxt_get();
    if (NULL != spdmContext)
    {
        if (NULL != spdmContext->xPLDMRespTimer)
        {
            if (xTimerStop(spdmContext->xPLDMRespTimer, 0) != pdPASS)
            {
                trace0(1, SB_MONITOR, 1, "Err:PLDMResp timer stop fail");
                return;
            }
        }
    }
}