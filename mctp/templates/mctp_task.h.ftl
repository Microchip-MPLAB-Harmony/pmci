<#--
/*******************************************************************************
  MCTP Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   mctp_task.h.ftl

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

#ifndef MCTP_TASK_H
#define MCTP_TASK_H

#include <stddef.h>
#include <stdint.h>
#include "mctp_common.h"
#include "mctp_config.h"

#ifdef __cplusplus
extern "C" {
#endif

/* MPU */
#define configMCTP_TASK1_PRIORITY MCTP_TASK_PRIORITY
#define MCTP_TASK1_PRIORITY ((tskIDLE_PRIORITY + configMCTP_TASK1_PRIORITY) % configMAX_PRIORITIES)
/* Stack size must be a power of 2 if the task is restricted */
#define MCTP_TASK1_STACK_SIZE 1024U       // 2 * configMINIMAL_STACK_SIZE (120)
#define MCTP_TASK1_STACK_WORD_SIZE ((MCTP_TASK1_STACK_SIZE) / 4U)
    
#define MCTP_TASK1_STACK_ALIGN __attribute__ ((aligned(MCTP_TASK1_STACK_SIZE)))

#define MCTP_TASK1_BUF_SIZE		512U
#define MCTP_TASK1_BUF_MPU_ATTR 0U
#define MCTP_TASK1_BUF_ALIGN __attribute__((aligned(MCTP_TASK1_BUF_SIZE)))

#define MCTP_EVENT_BIT              (1U << 1)
<#if MCTP_PHY_LAYER =="I2C" || (MCTP_PHY_LAYER =="I2C+SPI")> 
#define MCTP_I2C_ENABLE_BIT         (1U << 0)
#define MCTP_SMB_RESPONSE_BIT       (2U << 1)
</#if>
<#if MCTP_PHY_LAYER =="SPI" || (MCTP_PHY_LAYER =="I2C+SPI")> 
#define MCTP_SPT_CTRL_BIT           (1U << 3)
</#if>
#define MCTP_WAIT_FOR_SPDM_DONE     (1U << 18)
#define MCTP_WAIT_FOR_PLDM_DONE     (1U << 19)

/****************************************************************/
/** mctp_task1_get_handle
* Get the MCTP task handle
* @param  void
* @return TaskHandle_t - MCTP task handle
**********************************************************************/
extern TaskHandle_t mctp_task1_get_handle(void);

#ifdef __cplusplus
}
#endif

#endif /* MCTP_TASK_H */
