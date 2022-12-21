/*****************************************************************************
* � 2021 Microchip Technology Inc. and its subsidiaries.
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

/** @file spdm_crypto_ops.c
 * MEC1324 Peripheral common header file
 */
/** @defgroup MEC1324 Peripherals
 */

/*******************************************************************************
 *  MCHP version control information (Perforce):
 *
 *  FILE:     $ $
 *  REVISION: $Revision: #17 $
 *  DATETIME: $DateTime: 2022/10/24 02:21:55 $
 *  AUTHOR:   $Author: i65439 $
 *
 *  Revision history (latest first):
 *      # 1: Initial revision for the SPDM porting
 ***********************************************************************************
*/

// #include "../common/include/Glacier_bootrom_symbol_definitions.h"
#include "spdm_crypto_ops.h"
#include "spdm_common.h"
// #include "../secure_boot/sb_core/sb_dgst.h"
// #include "../secure_boot/sb_modules/sb_mem_map.h"
// #include "spdm_data_iso.h"

extern SPDM_BSS1_ATTR uint8_t pvt_key[PVT_KEY_CODE_LENGTH];

extern SPDM_BSS0_ATTR uint8_t hash_of_req_buffer[SHA384_BYTES];

extern SPDM_BSS0_ATTR ecdsa_signature_t ecdsa_signature __attribute__((aligned(8)));

extern SPDM_BSS0_ATTR uint8_t random_no[CURVE_384_SZ];
