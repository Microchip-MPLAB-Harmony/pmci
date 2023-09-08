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

#ifndef PLDM_TASK_H
#define PLDM_TASK_H

#include <stddef.h>
#include <stdint.h>
#include "pldm_common.h"
#include "mctp_config.h"

#ifdef __cplusplus
extern "C" {
#endif

#define configPLDM_PRIORITY (MCTP_TASK_PRIORITY - 1)
#define PLDM_PRIORITY ((tskIDLE_PRIORITY + configPLDM_PRIORITY) % configMAX_PRIORITIES)

/* Stack size must be a power of 2 if the task is restricted */
#define PLDM_STACK_SIZE 1024U       // 2 * configMINIMAL_STACK_SIZE (120)
#define PLDM_STACK_WORD_SIZE ((PLDM_STACK_SIZE) / 4U)

#define PLDM_STACK_ALIGN __attribute__ ((aligned(PLDM_STACK_SIZE)))

#define PLDM_TASK_BUF_SIZE 512U
#define PLDM_TASK_BUF_MPU_ATTR 0U


#define PLDM_EVENT_BIT                  (1 << 0u)
#define PLDM_RESP_EVENT_BIT             (1 << 1u)

int pldm_task_create(void *pvParams);

#define PLDM_TASK_LOG_MBOX_SIZE                    0x2000u
#define PLDM_TASK_LOG_MBOX_START_ADDR              0x126000u
#define PLDM_TASK_LOG_MBOX_MPU_ATTRIB              (portMPU_REGION_READ_ONLY | portMPU_REGION_EXECUTE_NEVER)

#define PLDM_TASK_BUF_ALIGN __attribute__((aligned(PLDM_TASK_BUF_SIZE)))

/** PLDM Task Modes */
enum PLDM_TASK_MODES
{
    PLDM_IDLE,
    PLDM_CMD_PROCESS_MODE,
    PLDM_CMD_GET_AP_CFG
};

/******************************************************************************/
/**  PLDM Context Information
*******************************************************************************/
typedef struct PLDM_CONTEXT
{
    /* Event group handle */
    EventGroupHandle_t xPLDMEventGroupHandle;

    /* Event group buffer*/
    StaticEventGroup_t xPLDMCreatedEventGroup;

    uint8_t pldm_state_info; // added this to track PLDM packets (if tracking with pldm_state_info, if pldm packet comes in between
    // pldm packets, the current state would go into toss)

    uint16_t pldm_current_request_length;

    uint8_t pldm_tx_state;

    uint8_t pldm_host_eid;

    uint8_t pldm_ec_eid;

    uint8_t pldm_ec_slv_addr;

    uint8_t pldm_host_slv_addr;

    uint8_t pldm_instance_id;

    uint8_t pldm_current_response_cmd;

    uint8_t pldm_current_state;

    uint8_t pldm_previous_state;  // maintaining this for sending previous state in GetStatus command

    uint8_t pldm_next_state;

    uint8_t pldm_verify_state;

    uint8_t pldm_apply_state;

    uint8_t pldm_status_reason_code;

    uint8_t current_pkt_sequence; // PLDM; used to find for packet loss and retry

    uint8_t expected_pkt_sequence;

    uint8_t pldm_cmd_code;
    
    /* PLDM timeout response Timer Handle*/
    TimerHandle_t xPLDMRespTimer;

    /* PLDM timeout response Timer buffer*/
    StaticTimer_t PLDMResp_TimerBuffer __attribute__((aligned(8)));

} __attribute__((packed)) PLDM_CONTEXT;

void pldm_init_task(PLDM_CONTEXT *pldmContext);
PLDM_CONTEXT* pldm_ctxt_get(void);

/******************************************************************************/
/** pldm_response_timeout_start
* Start the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_response_timeout_start(void);

/******************************************************************************/
/** pldm_response_timeout_stop
* Stop the software PLDMResponse timer
* @param void
* @return void
*******************************************************************************/
void pldm_response_timeout_stop(void);

#ifdef __cplusplus
}
#endif
#endif