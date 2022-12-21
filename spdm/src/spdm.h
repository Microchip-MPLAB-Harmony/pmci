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

/** @file spdm_iface.h
 * Interface header file for applications of SPDM
 */
/** @defgroup SPDM interface
 */

#ifndef SPDM_IFACE_H
#define SPDM_IFACE_H

#include "definitions.h"

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************/
/** Macro to define Certificate 0 Base Address
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * -----------------------
 * Certificate 0 Base Address
 * -----------------------
 * Configure Certificate 0 Base Address here, Certificate 1 will be at a offset
 * 0x400 from Certificate 0.
 * ############################################################################
*******************************************************************************/
#define CERTIFICATE_START_ADDRESS 0x126800

/******************************************************************************/
/** get_cert2_base_address
 * This function is to get Certificate 2 Address
 * @param cert_ptr         Pointer to hold certificate 2 address
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by SPDM module to get the Certificate 2 base address.
 * Remaining certificates 3 to 63 are at offset 0x400 from previous certificate.
 * -----------------------
 * Example:
 * -----------------------
 * spdm_pkt_initialize_cert_params_to_default
 * {
 *     get_cert2_base_address(&cert2_base_addr);
 * }
 *
 * void get_cert2_base_address(uint8_t *cert_ptr)
 * {
 *     read_cert2_addr(*cert_ptr);
 * }
 * ############################################################################
*******************************************************************************/
extern void get_cert2_base_address(uint32_t *cert_ptr);

/******************************************************************************/
/** spdm_get_measurements
 * This function can be used to get hash of measurement data. 
 * @param buff_ptr         Pointer to hold the measurement data
 * @param index            measurement id i.e. 0,1,2,3
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module to get hash of measurement data.
 * Currently 4 measurements are supported, unused measurement should be filled with
 * zero's.
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_get_measurements(uint8_t *buffer_ptr, uint8_t index)
 * {
 *      switch(index)
 *      {
 *          case 0:
 *              get_measurement_0_data(buffer_ptr);
 *              break;
 *          case 1:
 *              get_measurement_1_data(buffer_ptr);
 *              break;
 *           case 2:
 *              get_measurement_2_data(buffer_ptr);
 *              break;
 *          case 3:
 *              get_measurement_3_data(buffer_ptr);
 *              break;
 *          default:
 *              break;
 *      }
 * }
 * ############################################################################
*******************************************************************************/
extern void spdm_get_measurements(uint8_t *buffer_ptr,
                                    uint8_t index);

/******************************************************************************/
/** spdm_read_certificate
 * This function can be used to read the certificate data and store it in buffer. 
 * @param address          Address of certificate
 * @param buff_ptr         Pointer to hold certificate data
 * @param length           Length of the certificate to be read
 * @param certificate_no   Certificate number
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module to read certificate data. Root 
 * certificate of size 1KB is read, other certificates read length are 
 * decided by the size specified in the header. Certificate number passed can
 * be used to read certificate from corresponding peripherals.
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_read_certificate(uint32_t address, uint8_t *buffer_ptr, uint8_t length
 *                              uint8_t certificate_no)
 * {
 *      if (certificate_no == 0) {
 *          read_certificate_from_flash(address, buffer_ptr, length);
 *      } else if (certificate_no == 1) {
 *          read_certificate_from_ram(address, buffer_ptr, length);
 *      }
 * }
 * ############################################################################
*******************************************************************************/
extern uint8_t spdm_read_certificate(uint32_t address, 
                                  uint8_t *buff_ptr,
                                  uint32_t length,
                                  uint8_t certificate_num);


/******************************************************************************/
/** spdm_crypto_ops_gen_signature
 * This function can be used to generate signature. 
 * @param                  None
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module generate signature.
 * pvt_key array - must have the private key 
 * hash_of_req_buffer - must have the hash of the data
 * random_no - must have the random number for signature generation
 * ecdsa_signature.ecdsa_signature - will have the signature generated
 *  typedef union
    {
        struct
        {
            uint8_t signature_r_term[CURVE_384_SZ];
            uint8_t signature_s_term[CURVE_384_SZ];
        };
        uint8_t ecdsa_signature[CURVE_384_SZ*2];
    } ecdsa_signature_t;

    #define CURVE_384_SZ 48
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_crypto_ops_gen_signature()
 * {
 *      fill_pvt_key(&pvt_key[0]);
 * 
 *      generate_random_number(&random_no);
 * 
 *      ecdsa_gen_sig(&pvt_key[0], &hash_of_req_buffer[0], &random_no[0], &ecdsa_signature.ecdsa_signature[0]);
 * }
 * ############################################################################
*******************************************************************************/
extern uint32_t spdm_crypto_ops_gen_signature();

/******************************************************************************/
/** spdm_crypto_ops_calc_hash
 * This function can be used to calculate hash of data at single shot.
 * @param  buf_ptr         Pointer to data to be hashed
 * @param  length          Length of data to be hashed
 * @param  spdmContext     Holds the stage of hashing in case of intermediate
 *                         hashing
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module to calculate hash of data. 
 * Based on select value, hashing can be either single shot or intermediate
 * hashing.
 * spdmContext->get_requests_state will hold the hashing state in case of 
 * intermediate hashing.
 * The resultant hash has to be stored in spdmContext->sha_digest
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_crypto_ops_calc_hash(uint8_t *buff_ptr, uint32_t length, 
 *                                  SPDM_CONTEXT *spdmContext)
 * {
 *      
 * }
 * ############################################################################
*******************************************************************************/
extern void spdm_crypto_ops_calc_hash(uint8_t *buff_ptr, uint32_t length, 
                                    SPDM_CONTEXT *spdmContext);


/******************************************************************************/
/** spdm_crypto_ops_run_time_hashing
 * This function can be used to calculate hash of data at runtime.
 * @param  buf_ptr         Pointer to data to be hashed
 * @param  length          Length of data to be hashed
 * @param  spdmContext     Holds the stage of hashing in case of intermediate
 *                         hashing
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module to calculate hash of data. 
 * Based on select value, hashing can be either single shot or intermediate
 * hashing.
 * spdmContext->get_requests_state will hold the hashing state.
 * The resultant hash has to be stored in spdmContext->sha_digest.
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_crypto_ops_run_time_hashing(uint8_t *buff_ptr, uint32_t length, 
 *                                  SPDM_CONTEXT *spdmContext)
 * {
 *   uint8_t rc = 0x00;
 *
 *   if(NULL == spdmContext)
 *   {
 *       return 0xff;
 *   }
 *
 *   switch(spdmContext->get_requests_state)
 *   {
 *   case HASH_INIT_MODE:
 *       memset(&ctx_ptr, 0, sizeof(ctx_ptr));
 *       // initialize hash structure pointer to HW instance
 *       // allocate a descriptor to load hash configuration word
 *       rc = spdm_crypto_ops_hash_ctx_init(&ctx_ptr);
 *       if (rc != OK)
 *       {
 *           return rc;
 *       }
 *       break;
 *   case RUN_TIME_HASH_MODE:
 *       //populate internal buffer (128 bytes) upto 128 (block size)
 *       //feed to hash engine and calculate intermediate hash if internal buffer reaches max 128 bytes
 *       rc = spdm_crypto_ops_hash_ctx_update_buf(buff, &ctx_ptr, length);
 *       if (rc != OK)
 *       {
 *           return rc;
 *       }
 *       break;
 *   case END_OF_HASH:
 *       rc = spdm_crypto_ops_hash_ctx_final(&ctx_ptr, &spdmContext->sha_digest[0]);
 *       if (rc != OK)
 *       {
 *           return rc;
 *       }
 *       //switch back to init state as we got the final digest
 *       spdmContext->get_requests_state = HASH_INIT_MODE;
 *       break;
 *   default:
 *       break;
 *
 *   }
 *   return rc;
 *
 * }
 * ############################################################################
*******************************************************************************/
extern void spdm_crypto_ops_run_time_hashing(uint8_t *buff_ptr, uint32_t length,
                                    SPDM_CONTEXT *spdmContext);

/******************************************************************************/
/** spdm_crypto_ops_gen_random_no
 * This function can be used to generate random number.
 * @param  buff           Pointer to hold the generated random number
 * @param  bytes          Length of random number
 * @return                 None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the SPDM module to generate random number.
 * Resultant random number is stored in the address pointed by buff.
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t spdm_crypto_ops_gen_random_no(uint8_t *buff_ptr, uint32_t length)
 * {
 *    uint8_t ret = 0;
 *    ret = generate_random_num(buff_ptr, length); 
 *    return ret;  
 * }
 * ############################################################################
*******************************************************************************/
extern uint8_t spdm_crypto_ops_gen_random_no(uint8_t *buff, uint8_t bytes);
#ifdef __cplusplus
}
#endif

#endif /* SPDM_IFACE_H */

/**   @}
 */
