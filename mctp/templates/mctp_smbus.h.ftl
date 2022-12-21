<#--
/*******************************************************************************
  MCTP Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   mctp_smbus.h.ftl

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

#ifndef MCTP_SMBUS_H
#define MCTP_SMBUS_H

#include "mctp_common.h"
#include "mctp_base.h"
#include "mctp.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Supported SMBus Speed*/
#define SMBUS_AT_400_KHZ    1U
#define SMBUS_AT_100_KHZ    0U
/* Config Speed for Smbus either 400 or 100 Khz*/
#define SMBUS_SPEED_CONFIG  SMBUS_AT_400_KHZ

#define MCTP_SMBUS_AQ_TIMEOUT  100000U

/*MCTP Retry Couners */
#define MCTPSMBNKRET  0x08U
#define MCTPSMBLBRET  0x0FU
#define MCTPREQTOUT   0x0CU
#define MCTPREQRET    0x03U

#define INPUT_BUF_MAX_BYTES 1224U

/* function declarations */
uint8_t mctp_smbus_init(void);
void mctp_transmit_smbus(MCTP_PKT_BUF *tx_buf);
uint8_t mctp_receive_smbus(I2C_BUFFER_INFO *buffer_info, uint8_t slaveTransmitFlag);
uint8_t mctp_smbmaster_done(uint8_t channel, uint8_t status, uint8_t *buffer_ptr, I2C_MAPP_CBK_NEW_TX *newTxParams);
void mctp_smbdone_handler(MCTP_PKT_BUF *tx_buf);
void mctp_smbdone_drop(MCTP_PKT_BUF *pkt_buf);
void mctp_txpktready_init(MCTP_PKT_BUF *tx_buf);
uint8_t mctp_copy_rxpkt_for_ec(I2C_BUFFER_INFO *buffer_info);
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
uint8_t mctp_copy_rx_for_spdm_for_ec(I2C_BUFFER_INFO *buffer_info);
</#if>
extern void mctp_smbaddress_update(uint8_t smb_address, uint8_t mctp_port);
uint8_t packetize_data(uint8_t rx_packet_len, I2C_BUFFER_INFO *buffer_info, MCTP_PKT_BUF *rx_buf);

#define SET_MCTP_EVENT_TASK(mctp)   SET_MCTP_EVENT_FLAG()

<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
void SET_SPDM_EVENT_FLAG(void);
#define SET_EVENT_SPDM_TASK(spdm)   SET_SPDM_EVENT_FLAG()
</#if>
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
void SET_PLDM_EVENT_FLAG(void);
#define SET_EVENT_PLDM_TASK(pldm)   SET_PLDM_EVENT_FLAG()
</#if>
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
/**********************************************************************************************/
/** This is called when packet received over smbus is targeted for EC and message type is PLDM.
* @param *buffer_info Pointer to I2C_BUFFER_INFO structure of smbus layer
* @return void
***********************************************************************************************/
uint8_t mctp_copy_rx_for_pldm_for_ec(I2C_BUFFER_INFO *buffer_info);
</#if>

#ifdef __cplusplus
}
#endif

#endif /*MCTP_SMBUS_H*/
/**   @}
 */
