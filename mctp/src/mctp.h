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

/** @file mctp.h
 * Interface header file for MCTP
 */
/** @defgroup MCTP interface
 */

#ifndef MCTP_H    /* Guard against multiple inclusion */
#define MCTP_H

#include "definitions.h"
#include "mctp_common.h"
#include "mctp_base.h"

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************/
/** Global buffer to store MCTP. SPDM and PLDM request and response packets
 * mctp_pktbuf[MCTP_BUF1] - MCTP control request and response packet buffer
 * mctp_pktbuf[MCTP_BUF2] - SPDM response packet buffer
 * mctp_pktbuf[MCTP_BUF3] - SPDM request packet buffer
 * mctp_pktbuf[MCTP_BUF4] - PLDM request packet buffer
 * mctp_pktbuf[MCTP_BUF5] - PLDM response packet buffer
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * -----------------------
 * SPDM packet processing:
 * -----------------------
 * MCTP module will store SPDM request packets into mctp_pktbuf[MCTP_BUF3]
 * SPDM module is expected to read mctp_pktbuf[MCTP_BUF3], process the request
 * packet, and store the response packet into mctp_pktbuf[MCTP_BUF2]
 * Example:
 * MCTP_PKT_BUF *spdm_pkt_rx = mctp_pktbuf[MCTP_BUF3];
 * MCTP_PKT_BUF *spdm_pkt_tx = mctp_pktbuf[MCTP_BUF2];
 * Now use spdm_pkt_rx to process the received SPDM packet and use
 * spdm_tx_buf to populate the response packet
 * ############################################################################
 * -----------------------
 * PLDM packet processing:
 * -----------------------
 * MCTP module will store PLDM request packets into mctp_pktbuf[MCTP_BUF4]
 * PLDM module is expected to read mctp_pktbuf[MCTP_BUF4], process the request
 * packet, and store the response packet into mctp_pktbuf[MCTP_BUF5]
 * Example:
 * MCTP_PKT_BUF *pldm_pkt_rx = mctp_pktbuf[MCTP_BUF4];
 * MCTP_PKT_BUF *pldm_pkt_tx = mctp_pktbuf[MCTP_BUF5];
 * Now use spdm_pkt_rx to process the received SPDM packet and use
 * spdm_tx_buf to populate the response packet
 * ############################################################################
*******************************************************************************/
extern MCTP_BSS_ATTR MCTP_PKT_BUF mctp_pktbuf[MCTP_PKT_BUF_NUM]__attribute__ ((aligned(8)));

/******************************************************************************/
/** struct I2C_MAPP_CBK_NEW_TX
 * This structure is used to get information for new Tx from Application Callback
*******************************************************************************/
typedef struct I2C_MAPP_CBK_NEW_TX
{
    uint8_t *buffer_ptr;      /**< Application buffer */
    uint8_t smb_protocol;     /**< SMB Protocol */
    uint8_t WriteCount;       /**< Write Count */
    uint8_t pecEnable;        /**< PEC Enable/Disable Flag */
} I2C_MAPP_CBK_NEW_TX;

/******************************************************************************/
/** enum master_busy_status 
 * Enumeration to denote whether master is busy or ready to send the next packet
 * on the bus
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * The I2C driver is expected to use the values in this enumeration
 * when returning from mctp_i2c_get_chan_busy_status interface function
 * -----------------------
 * Example:
 * -----------------------
 * Refer mctp_i2c_get_chan_busy_status interface function
 * ############################################################################
*******************************************************************************/
enum master_busy_status
{
    MASTER_BUSY =0      /**< Master is busy, retry after sometime */
   , MASTER_AVAILABLE   /**< Master is available, go ahead with transaction */
};

/******************************************************************************/
/** enum slave_app_reg_status 
 * Enumeration to denote status codes for slave registration by application
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * The I2C driver is expected to use the values in this enumeration
 * when returning from mctp_i2c_rx_register interface function
 * -----------------------
 * Example:
 * -----------------------
 * Refer mctp_i2c_rx_register interface function
 * ############################################################################
*******************************************************************************/
enum slave_app_reg_status
{
     STATUS_ALREADY_REGISTERED = 0  /**< Application has already registered */
    , STATUS_MAX_APP_REGISTERED     /**< Maximum number of application registered */
    , STATUS_APP_NOT_REGISTERED     /**< Application is not registered */
    , STATUS_OK                     /**< Success status */
};

/******************************************************************************/
/** Status codes for master transaction. The error codes are for Bus Error,
 * MNAKX and PEC Error. The success codes are for successful tx and successful
 * rx (we could have only one success code, though)
 * @note
 * -----------------------
 * Usage notes:
 * -----------------------
 * The I2C driver is expected to use the values in this enumeration to communicate 
 * to the MCTP module about the packet transmission status 
 * -----------------------
 * Example:
 * -----------------------
 * Refer mctp_i2c_tx interface function
 *******************************************************************************/
enum master_status
{
    ERROR_BER_TIMEOUT =0        /**< Bus Error due to Timeout */
    , ERROR_BER_NON_TIMEOUT     /**< Bus Error due to Non Timeout */
    , ERROR_LAB                 /**< Lost Arbitration Error */
    , ERROR_MADDR_NAKX          /**< Slave sent Address NACK */
    , ERROR_MDATA_NAKX          /**< Slave sent Data NACK */
    , ERROR_SMB_DISABLED        /**< smbus is disabled thru Vreg */
    , ERROR_CLK_DATA_NOT_HIGH   /**< CLK or Data Not High */
    , ERROR_PEC                 /**< PEC Error */
    , SUCCESS_TX                /**< Successful Master Tx */
    , SUCCESS_RX                /**< Successful Master Rx */
    , SUCCESS_TX_CHAINED        /**< Successful Master Tx for chained transfer - intermediate status*/
    , SUCCESS_RX_CHAINED        /**< Successful Master Rx for chained transfer - intermediate status*/
};

/******************************************************************************/
/** Application return values
 * Action codes to the I2C driver about the action to take for the current
 * packet
 * @note
 * -----------------------
 * Usage notes:
 * -----------------------
 * The MCTP module will use the values in this enumeration to communicate to the
 * i2c driver about the action to take with the current packet, when the i2c driver
 * communicates about the transmission status to the MCTP module (refer mctp_i2c_tx)
 * The I2C driver is expected to take relevent action
 *******************************************************************************/
enum application_return_values
{
    APP_RETVAL_RELEASE_SMBUS =0     /**< Application releases hold on smbus */
    , APP_RETVAL_HOLD_SMBUS         /**< Application still acquires smbus */
    , APP_RETVAL_RETRY              /**< Application wants to retry the current transaction */
    , APP_RETVAL_NEW_TX             /**< Application wants to start new Master TX immediately */
    , APP_RETVAL_CHAINED_RX         /**< Application is continuing a chained RX transaction */
    , APP_RETVAL_CHAINED_RX_LAST    /**< Last request for a chained RX transaction */
    , APP_RETVAL_CHAINED_TX         /**< Application is continuing a chained TX transaction */
    , APP_RETVAL_CHAINED_TX_LAST    /**< Last request for a chained TX transaction */
};

/******************************************************************************/
/** i2c_bus_speed 
 * I2C bus speed values
 * @note
 * -----------------------
 * Usage notes:
 * -----------------------
 * The values in this enum are used by MCTP module to identify I2C bus speed
 * values
 *******************************************************************************/
enum i2c_bus_speed
{
    SMBUS_SPEED_100KHZ
   ,SMBUS_SPEED_400KHZ
   ,SMBUS_SPEED_1MHZ
};

/******************************************************************************/
/** i2c_slave_packet_status 
 * Values used by MCTP module to return the status of packet acceptance
 * @note
 * -----------------------
 * Usage notes:
 * -----------------------
 * The values in this enum are used by MCTP module to notify the I2C driver 
 * if it accepted the provided packet or not
 *******************************************************************************/
enum i2c_slave_packet_status
{
    STATUS_BUFFER_NOT_DONE= 0   /**< Packet not accepted, since application is busy */
    ,STATUS_BUFFER_DONE         /**< Packet accepted by application */
    ,STATUS_BUFFER_ERROR        /**< Packet not meant for this application */
};

/******************************************************************************/
/** i2c_slave_transmit_status 
 * Values used by MCTP module to check for i2c slave transmit protocol
 * @note
 * -----------------------
 * Usage notes:
 * -----------------------
 * The user's i2c driver is expected to use the values in this enumeration
 * to notify the MCTP module if it is expecting a packet as part of slave transmit
 * phase
 *******************************************************************************/
enum i2c_slave_transmit_status
{
    SLAVE_TRANSMIT_FALSE = false    /**< Slave Transmit phase not required */
    ,SLAVE_TRANSMIT_TRUE= true      /**< Slave Transmit phase required */
};

/******************************************************************************/
/** struct I2C_BUFFER_INFO
 * This structure is used to store information of a slave receive buffer XmitCount
 * is used along with slaveXmitDoneFlag for chaining slave transmit data
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * The I2C driver is expected allocate a structure of this type and use it
 * to pass information to MCTP module about the received packet
 * -----------------------
 * Example:
 * -----------------------
 * Refer SLAVE_FUNC_PTR
*******************************************************************************/
typedef struct I2C_BUFFER_INFO
{
    uint8_t *   buffer_ptr;          /**< Pointer to buffer memory */
    uint16_t    TimeStamp;           /**< Packet received timestamp */
    uint8_t     DataLen;             /**< Data Length of packet received */
    uint8_t     XmitCount;           /**< Number of times slave has transmitted using this buffer for this transaction */
    uint8_t     RxCount;             /**< Number of times slave has received using this buffer for this transaction */
    uint8_t     pecFlag;             /**< PEC valid/invalid flag */
    uint8_t     slaveXmitDoneFlag;   /**< Flag indicating if xmit is completed by slave application */
    uint8_t     channel;             /**< Channel on which this packet is received */
    bool        sdoneFlag;           /**< Flag to indicate if SDONE occured for this buffer */
} I2C_BUFFER_INFO;

/******************************************************************************/
/** SLAVE_FUNC_PTR - Slave application function pointer
 * The first argument is pointer to I2C_BUFFER_INFO structure which will contain
 * details of the packet received. The second parameter is flag to indicate
 * slave transmit phase. In case of slave transmit phase, the application
 * should provide the data to be transmitted in the same buffer and indicate
 * whether PEC should be enabled for transmit phase
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * The I2C driver is expected allocate a structure of this type and use it
 * to pass information to MCTP module about the received packet
 * -----------------------
 * Example:
 * -----------------------
 * struct i2c_packet_t
 * {
 *     uint8_t i2c_rx_buff[MAX_I2C_PKT_LEN];
 *     uint8_t len;
 * };
 * struct i2c_packet i2c_pkt[MAX_I2C_CHANNELS];
 * I2C_BUFFER_INFO i2c_rx_packet;
 * 
 * uint8_t i2c_store_rxd_pkt(channel, uint8_t *data, uint8_t len)
 * {
 *     memcpy(&i2c_pkt[channel].i2c_rx_buff[0], data, len);
 *     i2c_pkt[channel].len = len;
 * }
 * 
 * uint8_t i2c_process_mctp_pkt(uint8_t channel)
 * {
 *      i2c_rx_packet.buffer_ptr = i2c_pkt[channel];
 *      i2c_rx_packet.TimeStamp  = get_current_timestamp();
 *      i2c_rx_packet.DataLen    = i2c_pkt[channel].len;
 *      i2c_rx_packet.pecFlag    = 1;
 *      i2c_rx_packet.channel    = channel;
 * 
 *      mctp_rx_cb[channel](&i2c_rx_packet, SLAVE_TRANSMIT_FALSE);
 * }
 * ############################################################################
 * -----------------------
 * Note:
 * -----------------------
 * 1. Please note that the minimum packet length is 12 bytes
 *    which includes destination slave address and PEC byte 
 * 2. MCTP does not support slave transmit protocol - Refer MCTP over I2C/SMBUS
 *    transport binding specification, section 6.3 for further details
 * ############################################################################
 * ############################################################################
*******************************************************************************/
typedef uint8_t (*SLAVE_FUNC_PTR)(I2C_BUFFER_INFO *, uint8_t);

/******************************************************************************/
/** MASTER_FUNC_PTR - Master transmit status function pointer
 * This function pointer should be saved by the I2C driver and called later
 * to inform the MCTP module about the status of the packet transmission.
 * The first parameters should contain the channel information
 * The second parameter should contian the packet transmission status,
 * refer enum MasterStatus for a list of valid values
 * The third parameter should contain a pointer to the transmit buffer being 
 * containing the packet currently being transmitted
 * The fourth parameter is reserved for furture use and is currently ignored
 * by the MCTP module
 * A function of this type will return a status code to the caller which 
 * will be of type enum ApplicationReturnValues
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * When MCTP module initiates a packet transmission using mctp_i2c_tx interface
 * function, it also provides a pointer to a function of this type to the 
 * I2C driver, which is expected to be saved by the I2C driver. The I2C driver
 * is then expected to call this function after every packet sent on the bus
 * to inform the MCTP module about the status of the transmission. Based on 
 * status code, mctp layer will schedule re-transmission of packet or drop the 
 * packet / mark buffer available by returning one of the values of type 
 * enum ApplicationReturnValues
 * -----------------------
 * Example:
 * -----------------------
 * Refer mctp_i2c_tx interface function
 * ############################################################################
*******************************************************************************/
typedef uint8_t (*MASTER_FUNC_PTR)(uint8_t, uint8_t, uint8_t *, I2C_MAPP_CBK_NEW_TX *);

/******************************************************************************/
/** mctp_i2c_tx
 * Initiates I2C master operation
 * @param channel          i2c channel
 * @param buffer_ptr       Buffer for the smbus transaction
 * @param smb_protocol     smbus protocol byte
 * @param pecEnable        Flag to enable/disable PEC
 * @param WriteCount       Number of bytes to transmit
 * @param di_master_req    Data Isolation structure
 * @param readChainedFlag  flag to indicate if read needs to be done
 *                         using dma chaining
 * @param writeChainedFlag flag to indicate if write needs to be done
 *                         using dma chaining
 * @return                 MASTER_OK on success, MASTER_ERROR if i2c is 
 *                         not ready for master mode operation
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the MCTP module whenever it wants to
 * initiate a master transaction on the bus. If this function returns
 * MASTER_ERROR, the MCTP module will retry after some time
 * For SMBUS ReadBlock protocol the application should provide a 80 byte
 * buffer. This function should be defined by the user and a call to the
 * driver i2c master mode write function should be made inside the body.
 * If the user i2c driver is busy carrying out some other operation
 * the user should return MASTER_ERROR otherwise the user should return 
 * MASTER_OK while exiting this function.
 * -----------------------
 * Example:
 * -----------------------
 * MASTER_FUNC_PTR i2c_tx_status i2c_tx_status_cb;
 * uint8_t i2c_tx_status[MAX_I2C_CHANNELS];
 * uint8_t i2c_tx_done[MAX_I2C_CHANNELS];
 * uint8_t *tx_buffer = NULL;
 * uint8_t mctp_i2c_tx(const uint8_t channel, uint8_t *buffer_ptr, const uint8_t smb_protocol, 
 *                     const uint8_t writeCount, MASTER_FUNC_PTR func_ptr, const uint8_t pecEnable, 
 *                     const uint8_t readChainedFlag, const uint8_t writeChainedFlag);
 * {
 *     uint8_t status = MASTER_OK;
 *     i2c_tx_status[channel] = SUCCESS_TX;
 *     i2c_tx_status_cb = func_ptr;
 *     tx_buffer = buffer_ptr;
 *     status = i2c_write_data(channel, buffer_ptr, writeCount, pecEnable);
 *     if(status < 0)
 *     {
 *          status = MASTER_ERROR;
 *     }
 *     return status;
 * }
 * 
 * void i2c_tx_isr(void)
 * {
 *     uint8_t channel;
 *     for(channel=0; channel<MAX_I2C_CHANNELS; channel++)
 *     {
 *         i2c_tx_done[channel] = i2c_get_tx_done(channel);
 *         i2c_tx_status[channel] = i2c_get_tx_status(channel);
 *     }
  * }
 * 
 * void i2c_send_tx_status(void)
 * {
 *     uint8_t channel = 0;
 *     for(channel=0; channel<MAX_I2C_CHANNELS; channel++)
 *     {
 *         if(i2c_tx_done[channel] == true)
 *         {
 *             switch(i2c_tx_status[channel])
 *             {
 *                 case TX_ERROR_BUS_ERR:
 *                 status = ERROR_BER_NON_TIMEOUT;
 *                 break;
 *                 case TX_ERROR_BUS_ERR_TOUT:
 *                 status = ERROR_BER_TIMEOUT;
 *                 break;
 *                 case TX_ERROR_LOST_ARB:
 *                 status = ERROR_LAB;
 *                 break;
 *                 case TX_ERROR_ADDR_NACK:
 *                 status = ERROR_MADDR_NAKX;
 *                 break;
 *                 case TX_ERROR_DATA_NACK:
 *                 status = ERROR_MDATA_NAKX;
 *                 break;
 *                 case TX_ERROR_PEC:
 *                 status = ERROR_PEC;
 *                 break;
 *                 case TX_ERROR_CHAN_DISABLED:
 *                 status = ERROR_SMB_DISABLED;
 *                 break;
 *                 default:
 *             }
 *             i2c_tx_status_cb(channel, status, tx_buffer, NULL);
 *         }
 *     }
 * }
 * ############################################################################
*******************************************************************************/
extern uint8_t mctp_i2c_tx(const uint8_t channel, 
                    uint8_t *buffer_ptr, 
                    const uint8_t smb_protocol, 
                    const uint8_t writeCount, 
                    const uint8_t pecEnable, 
                    MASTER_FUNC_PTR func_ptr, 
                    const uint8_t readChainedFlag,
                    const uint8_t writeChainedFlag);

/******************************************************************************/
/** mctp_i2c_rx_register
 * This function registers a I2C slave application
 * @channel the channel on which the slave is registered
 * @param slaveFuncPtr The application function to call on receiving a packet
 * @return             STATUS_OK on successful registration, else error status
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * Whenever an application expects data from smbus (i.e acts as slave) it
 * needs to register using this function.
 * The application function that is registered should only copy the
 * packet from smbus buffer, it should not the process the data in that
 * function
 * -----------------------
 * Example:
 * -----------------------
 * SLAVE_FUNC_PTR mctp_rx_cb[MAX_I2C_CHANNELS];
 * uint8_t mctp_i2c_rx_register(const uint8_t channel, SLAVE_FUNC_PTR slaveFuncPtr)
 * {
 *     uint8_t status = STATUS_APP_NOT_REGISTERED;
 *      
 *     do
 *     {
 *         if(channel > MAX_I2C_CHANNELS)
 *         {
 *             status = STATUS_MAX_APP_REGISTERED;
 *             break;
 *         }
 *         
 *         if(mctp_rx_cb[channel] != NULL)
 *         {
 *             status = STATUS_ALREADY_REGISTERED;
 *             break;
 *         }
 *         
 *         mctp_rx_cb[channel] = slaveFuncPtr;
 *         status = STATUS_OK;
 *     }
 *     while(0);
 * }
 * ############################################################################
*******************************************************************************/
extern uint8_t mctp_i2c_rx_register(const uint8_t channel, 
                            SLAVE_FUNC_PTR slaveFuncPtr);

/******************************************************************************/
/** mctp_i2c_configure_and_enable
 * This function can be used to start and enable the i2c controller
 * @param channel     channel, check enums in smb.h
 * @param own_address 7-bit smb address
 * @param speed       speed, check enums in smb.h
 * @param port        default port on the controller
 * @param configFlag  |      BIT0      |      BIT1      |      BIT2      |    BIT3 - BIT7 |
 *                    | i2c module     |     Unused     | MCTP fairness  |      Unused    |
 *                    | enable/disable |                |protocol enable |                |
 * @return            None
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the MCTP task with all parameters being populated
 * from the user selection in MCC project configuration. The user is expected
 * to define this function in his application and call their i2c driver 
 * initialization routine making use of parameters as needed by the driver
 * routine. 
 * The configFlag paramter is optional and if the user's driver does
 * not support MCTP fairness protocol it can disacard this parameter.
 * The port parameter is optional and if the user driver supports only 
 * one controller, it can discard this parameter
 * The channel parameter is used in case the user's driver supports 
 * more than one channel per i2c controller. Otherwise, the user can 
 * discard this parameter
 * -----------------------
 * Example:
 * -----------------------
 * void mctp_i2c_configure_and_enable(uint8_t channel, 
 *                                    uint16_t own_address, 
 *                                    uint8_t speed, 
 *                                    uint8_t port, 
 *                                    uint8_t configFlag)
 * {
 *      uint8_t fairness_proto_en = (config_Flag & 0x04);
 *      i2c_configure(channel, own_address, speed, fairness_proto_en);
 *      i2c_start(channel);
 * }
 * ############################################################################
*******************************************************************************/
extern void mctp_i2c_configure_and_enable(uint8_t channel, 
                                   uint16_t own_address, 
                                   uint8_t speed, 
                                   uint8_t port, 
                                   uint8_t configFlag);

/******************************************************************************/
/** mctp_i2c_get_chan_busy_status
 * This function checks if master resource is available on a given
 * channel
 * @param channel i2c channel
 * @return MASTER_AVAILABLE/MASTER_BUSY
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the MCTP module to check if an I2C channel is
 * busy performing some other operation. The MCTP module will wait for the 
 * I2C channel to be free before calling mctp_i2c_tx interface function. The
 * user is expected to define this function in his application and call their
 * i2c driver function inside the body to check for channel busy status. Refer
 * enum master_busy_status
 * -----------------------
 * Example:
 * -----------------------
 * uint8_t mctp_i2c_get_chan_busy_status(uint8_t channel)
 * {
 *      uint8_t status = MASTER_BUSY;
 *      if(i2c_is_channel_busy(channel) == False)
 *      {
 *          status = MASTER_AVAILABLE
 *      }
 *      return status;
 * }
 * ############################################################################
*******************************************************************************/
extern uint8_t mctp_i2c_get_chan_busy_status(uint8_t channel);

/******************************************************************************/
/** mctp_i2c_get_current_timestamp
 * Function to retrieve the current timestamp
 * @param None
 * @return 16-bit timestamp value
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function is called by the MCTP module to check if for packet timeouts.
 * The user expected to define this function and call xTaskGetTickCount()
 * API of FreeRTOS depending on the rate at which their i2c driver task is
 * running
 * -----------------------
 * Usage notes:
 * -----------------------
 * Assume user i2c driver task running every 10 RTOS ticks
 * uint16_t mctp_i2c_get_current_timestamp(void)
 * {
 *     return (uint16_t) (xTaskGetTickCount() / 10);
 * }
 * ############################################################################
 ******************************************************************************/
extern uint16_t mctp_i2c_get_current_timestamp(void);

/******************************************************************************/
/** SET_MCTP_EVENT_FLAG()
 * Set event flag to trigger MCTP packet processing
 * @param  none
 * @return none
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * This function should be called by SPDM module when an SPDM response packet
 * has been populated in mctp_pktbuf[MCTP_BUF2] and ready to be processed
 * by MCTP module
 * -----------------------
 * Usage notes:
 * -----------------------
 * MCTP_PKT_BUF *spdm_buf_tx = MCTP_NULL;
 * MCTP_PKT_BUF *spdm_buf_rx = MCTP_NULL;
 * void spdm_packet_process(void)
 * {
 *      spdm_buf_rx = mctp_pktbuf[MCTP_BUF3];
 *      spdm_buf_tx = mctp_pktbuf[MCTP_BUF2];
 *      spdm_populate_reponse(spdm_buf_rx, spdm_buf_tx);
 *      SET_MCTP_EVENT_FLAG();
 * }
 * ############################################################################
*******************************************************************************/
void SET_MCTP_EVENT_FLAG(void);

/******************************************************************************/
/** SET_SPDM_EVENT_FLAG()
 * Set event flag to trigger SPDM packet processing
 * @param  none
 * @return none
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * When the MCTP module identifies that the received packet is an SPDM packet,
 * it stores the packet into mctp_pktbuf[MCTP_BUF3], and calls this function.
 * This function should be defined by the user's SPDM module and should ideally
 * include an IPC mechanism to trigger the user's SPDM module.
 * -----------------------
 * Example:
 * -----------------------
 * Assume that user SPDM task is using eventgroups for notifications from 
 * other tasks and uses BIT0 to wait and trigger SPDM packet processing event
 * 
 * EventGroupHandle_t spdmEventGroupHandle;
 * StaticEventGroup_t spdmCreatedEventGroup;
 * 
 * int spdm_task_create(void *pvParams)
 * {
 *      spdmEventGroupHandle = xEventGroupCreateStatic(spdmCreatedEventGroup);
 *      // User SPDM task creation
 *      // assume task routine = spdm_task
 * }
 * 
 * static void spdm_task(void* pvParameters)
 * {
 *     EventBits_t uxBits;
 *     uxBits = xEventGroupWaitBits(spdmEventGroupHandle, SPDM_EVENT_BIT, pdTRUE, pdFALSE, portMAX_DELAY);
 *     if (SPDM_EVENT_BIT == (uxBits & SPDM_EVENT_BIT))
 *     {
 *          // User SPDM packet processing routine(s)
 *     }
 * }
 * 
 * void SET_SPDM_EVENT_FLAG(void)
 * {
 *      xEventGroupSetBits(spdmEventGroupHandle, SPDM_EVENT_BIT);
 * }
 * ############################################################################
*******************************************************************************/
extern void SET_SPDM_EVENT_FLAG(void);

/******************************************************************************/
/** SET_PLDM_EVENT_FLAG()
 * Set event flag to trigger PLDM packet processing
 * @param  none
 * @return none
 * @note
 * ############################################################################
 * -----------------------
 * Usage notes:
 * -----------------------
 * When the MCTP module identifies the received packet as being an PLDM packet,
 * it stores the packet into mctp_pktbuf[MCTP_BUF3], and calls this function.
 * This function should be defined by the user's PLDM module and should ideally
 * include an IPC mechanism to trigger the user's PLDM module.
 * -----------------------
 * Example:
 * -----------------------
 * Assume that user PLDM task is using eventgroups for notifications from 
 * other tasks and uses BIT0 to wait and trigger PLDM packet processing event
 * 
 * EventGroupHandle_t pldmEventGroupHandle;
 * StaticEventGroup_t pldmCreatedEventGroup;
 * 
 * int pldm_task_create(void *pvParams)
 * {
 *      pldmEventGroupHandle = xEventGroupCreateStatic(pldmCreatedEventGroup);
 *      // User PLDM task creation
 *      // assume task routine = pldm_task
 * }
 * 
 * static void pldm_task(void* pvParameters)
 * {
 *     EventBits_t uxBits;
 *     uxBits = xEventGroupWaitBits(pldmEventGroupHandle, PLDM_EVENT_BIT, pdTRUE, pdFALSE, portMAX_DELAY);
 *     if (PLDM_EVENT_BIT == (uxBits & PLDM_EVENT_BIT))
 *     {
 *          // User PLDM packet processing routine(s)
 *     }
 * }
 * 
 * void SET_PLDM_EVENT_FLAG(void)
 * {
 *      xEventGroupSetBits(pldmEventGroupHandle, PLDM_EVENT_BIT);
 * }
 * ############################################################################
*******************************************************************************/
extern void SET_PLDM_EVENT_FLAG(void);

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* MCTP_H */

/* *****************************************************************************
 End of File
 */