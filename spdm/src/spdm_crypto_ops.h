/*****************************************************************************
* Copyright (c) 2022 Microchip Technology Inc.
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

/** @file spdm_crypto_ops.h
 *  Header file for SPDM crypto operations
 */

/*******************************************************************************
 *  MCHP version control information (Perforce):
 *
 *  FILE:     $ $
 *  REVISION: $Revision: #11 $
 *  DATETIME: $DateTime: 2022/09/19 23:31:00 $
 *  AUTHOR:   $Author: i67071 $
 *
 *  Revision history (latest first):
 *      # 1: Initial revision for the MCTP porting
 ***********************************************************************************
*/

#ifndef SPDM_CRYPTOS_H
#define SPDM_CRYPTOS_H

#include <stddef.h>
#include <stdint.h>

#define SHA384_BYTES                                   48U
#define CURVE_384_SZ                                   48U

enum SPDM_RQS_STATE
{
    HASH_INIT_MODE,
    RUN_TIME_HASH_MODE,
    END_OF_HASH
};

typedef union
{
    struct
    {
        uint8_t signature_r_term[CURVE_384_SZ];
        uint8_t signature_s_term[CURVE_384_SZ];
    };
    uint8_t ecdsa_signature[CURVE_384_SZ*2U];
} ecdsa_signature_t;

#endif