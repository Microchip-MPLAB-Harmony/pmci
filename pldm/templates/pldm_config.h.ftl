<#--
/*******************************************************************************
  PLDM Freemarker Template File

  Company:
    Microchip Technology Inc.

  File Name:
   pldm_config.h.ftl

  Summary:
    PLDM Freemarker Template File

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

/** @file pldm_config.h
 *  PLDM configuration header file
 */
/** @defgroup PLDM Configuration
 */

#ifndef PLDM_CONFIG_H
#define PLDM_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif


#define PLDM_DEVICE_DESCRIPTOR_OVERRIDE   0x${PLDM_DEVICE_DESCRIPTOR_OVERRIDE}
#define PLDM_OVERRIDE_CAPABLITIES         0x${PLDM_OVERRIDE_CAPABLITIES}
#define PLDM_OVERRIDE_COMP_CLASSIFICATION 0x${PLDM_OVERRIDE_COMP_CLASSIFICATION}
#define PLDM_DEVICE_IDENTIFIER_LENGTH     0x${PLDM_DEVICE_IDENTIFIER_LENGTH}
#define PLDM_DESCRIPTOR_COUNT             0x${PLDM_DESCRIPTOR_COUNT}

<#assign byte_num = 0>
<#list 0..49 as i>
#define PLDM_DESCRIPTOR_${byte_num} 0x${.vars["PLDM_DESCRIPTOR_"+(byte_num)+"_"+(byte_num+1)+"_"+(byte_num+2)+"_"+(byte_num+3)]}
<#assign byte_num = byte_num+4>
</#list>
#define GET_DESC(x)  PLDM_DESCRIPTOR_##x

#define PLDM_UPGRADE_CAPABLITIES          0x${PLDM_UPGRADE_CAPABLITIES}

#define PLDM_COMP_CLASSIFICATION          0x${PLDM_COMP_CLASSIFICATION}
#define PLDM_DEVICE_TID                   0x${PLDM_DEVICE_TID}


#ifdef __cplusplus
}
#endif

#endif /* PLDM_CONFIG_H */

/**   @}
 */