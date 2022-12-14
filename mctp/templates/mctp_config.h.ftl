<#--
/*******************************************************************************
  MCTP Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   mctp_config.h.ftl

  Summary:
    MCTP Freemarker Template File

  Description:

*******************************************************************************/
-->
/*****************************************************************************
* Copyright (c) 2022 Microchip Technology Inc. and its subsidiaries.
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

#ifndef MCTP_CONFIG_H
#define MCTP_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif

#include "mctp.h"

#define HOST_SLAVE_ADDR                        0x${MCTP_EC_SLAVE_ADDR}
#define MCTP_EC_EID                            0x${MCTP_EC_EID}
#define MCTP_HOST_EID                          0x${MCTP_HOST_EID}
#define MCTP_TASK_PRIORITY                     ${MCTP_TASK_PRIORITY}U
#define MCTP_I2C_PORT                          ${MCTP_I2C_PORT}U
#define MCTP_I2C_CHANNEL                       ${MCTP_I2C_CONTROLLER}U
<#if MCTP_I2C_CLK_FREQ == "1000">
#define MCTP_I2C_CLK_FREQ                      I2C_BUS_SPEED_1MHZ
<#elseif MCTP_I2C_CLK_FREQ == "400">
#define MCTP_I2C_CLK_FREQ                      I2C_BUS_SPEED_400KHZ
<#else> <#-- MCTP_I2C_CLK_FREQ == 100 -->
#define MCTP_I2C_CLK_FREQ                      I2C_BUS_SPEED_100KHZ
</#if>

#ifdef __cplusplus
}
#endif

#endif /* MCTP_CONFIG_H */

/**   @}
 */