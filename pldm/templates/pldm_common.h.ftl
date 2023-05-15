/****************************************************************************
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

#ifndef PLDM_COMMON_H
#define PLDM_COMMON_H

// #include "FreeRTOS.h"
// #include "task.h"
// #include "event_groups.h"
// #include "../mctp/mctp_base.h"
// #include "../mctp/mctp.h"
#include "pldm_config.h"

#ifdef __cplusplus
extern "C" {
#endif

<#if PLDM_IS_SG3_COMPONENT_CONNECTED == true>
#define PLDM_BSS0_ATTR                                     __attribute__((section("spdm_bss0")))
#define PLDM_BSS1_ATTR                                     __attribute__((section("spdm_bss1")))
#define PLDM_BSS2_ATTR                                     __attribute__((section("spdm_bss2")))
<#else>
#define PLDM_BSS0_ATTR                                     __attribute__((section("pldm_bss0")))
#define PLDM_BSS1_ATTR                                     __attribute__((section("pldm_bss1")))
#define PLDM_BSS2_ATTR                                     __attribute__((section("pldm_bss2")))
</#if>

// #define PVT_KEY_CODE_LENGTH               (96U)
// #define PLDM_SHA384_LEN                   (48U)
// #define CURVE_384_SZ                      (48U)


// #define STATUS_OK 0U

#define is_add_safe(sum, aug_or_add) ((sum) < (aug_or_add) ? 0 : 1) // Coverity INT30-C Postcondition Test
#define is_sub_safe(ui_a, ui_b) ((ui_a) < (ui_b) ? 0 : 1) // Coverity INT30-C Precondition Test

// typedef union
// {
//     struct
//     {
//         uint8_t signature_r_term[CURVE_384_SZ];
//         uint8_t signature_s_term[CURVE_384_SZ];
//     };
//     uint8_t ecdsa_signature[CURVE_384_SZ*2];
// } ecdsa_signature_t;


// /******************************************************************************/
// /** safe_subraction_16
// * Process safe subtraction of two variables of uint16
// * @param uint16_t  - operand 1
// * @param uint16_t  - operand 2
// * @param uint16_t* - resultant pointer
// * @return uint8_t  - 0 success
// *******************************************************************************/
// uint8_t safe_subraction_16(uint16_t minuend, uint16_t subtrahend, uint16_t * rslt);

#ifdef __cplusplus
}
#endif

#endif