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

#include "definitions.h"

#include "mctp.h"
#include "mctp_common.h"
#include "mctp_base.h"
#include "mctp_smbus.h"
#include "mctp_control.h"
#include "mctp_config.h"

extern void mctp_test_init(void);
/* function declarations */
void mctp_init_buffers(void);
uint8_t mctp_tx_timeout(MCTP_PKT_BUF *pktbuf);
void mctp_event_tx_handler(void);
void mctp_event_rx_handler(void);
void mctp_handle_ec_rx_request_pkt(void);

extern MCTP_BSS_ATTR uint8_t smb_channel_busy_status;

MCTP_BSS_ATTR MCTP_PKT_BUF mctp_pktbuf[MCTP_PKT_BUF_NUM]__attribute__ ((aligned(8)));

/* mctp tx state machine variables */
MCTP_BSS_ATTR uint8_t mctp_tx_state;
MCTP_BSS_ATTR uint8_t mctp_txbuf_index;
MCTP_BSS_ATTR uint8_t mctp_wait_smbus_callback;

MCTP_BSS_ATTR uint8_t packetizing = false;
MCTP_BSS_ATTR uint8_t store_msg_type_state; // pldm or spdm or mctp
MCTP_BSS_ATTR uint8_t store_msg_type_tx; // pldm or spdm or mctp - when transmitting multiple/single pkt through smbus
MCTP_BSS_ATTR uint8_t store_msg_tag; // Store Tag
MCTP_BSS_ATTR uint8_t pkt_seq_num; // Store pkt seq num
MCTP_BSS_ATTR uint8_t out_of_seq_detected;

/* extern variables */
//struct MCTP_CFG_PARA mctp_cfg;
MCTP_BSS_ATTR struct MCTP_CFG_PARA mctp_cfg;
MCTP_BSS_ATTR struct MCTP_IDENTITY mctp_self;
MCTP_BSS_ATTR uint8_t cmd_field = 0x00;

MCTP_BSS_ATTR uint8_t transmit_buf[sizeof(MCTP_BUFDATA)]__attribute__ ((aligned(8))) = {0x00};

MCTP_BSS_ATTR uint32_t start_time;

/******************************************************************************/
/** UPDATES packetizing variable to check if input data spans more than one mctp packet
* @param NULL
* @return true/false
*******************************************************************************/
uint8_t mctp_base_packetizing_val_get()
{
    return packetizing;
}

/******************************************************************************/
/** UPDATES packetizing variable to check if input data spans more than one mctp packet
* @param val = true/false
* @return None
*******************************************************************************/
void mctp_base_packetizing_val_set(uint8_t val)
{
    packetizing = val;
}

/******************************************************************************/
/** UPDATES CURRENT_EID FIELD OF RESPECTIVE ENDPOINT OF MCTP BRIDGE ROUTING TABLE
* @param i Endpoint entry id
* @return void
*******************************************************************************/
void mctp_rtupdate_current_eid(uint8_t i)
{
    trace0(0, MCTP, 0, "MTP rtupd_eid: Enter");
    trace1(0, MCTP, 0, "MTP_rtupd_eid: i = %Xh", i);

    if(mctp_rt.epA.ep[i].field.default_eid != 0) /* means static eid config */
    {
        mctp_rt.epA.ep[i].field.current_eid = mctp_rt.epA.ep[i].field.default_eid;
    }

} /* End mctp_rtupdate_current_eid */

/******************************************************************************/
/** UPDATES EID_TYPE FIELD OF RESPECTIVE ENDPOINT OF MCTP BRIDGE ROUTING TABLE
* @param i Endpoint entry id
* @return void
*******************************************************************************/
void mctp_rtupdate_eid_type(uint8_t i)
{
    trace0(0, MCTP, 0, "mctp_rtupd_eid_type: Enter");
    trace1(0, MCTP, 0, "mctp_rtupd_eid_type: i = %Xh", i);

    if(mctp_rt.epA.ep[i].field.default_eid == 0) /* means dynamic eid config */
    {
        mctp_rt.epA.ep[i].field.eid_type = MCTP_DYNAMIC_EID;
    }
    else if(mctp_rt.epA.ep[i].field.default_eid != 0) /* means static eid config */
    {
        if(mctp_rt.epA.ep[i].field.current_eid == mctp_rt.epA.ep[i].field.default_eid)
        {
            mctp_rt.epA.ep[i].field.eid_type = MCTP_STATIC_DEQC;
        }
        else if(mctp_rt.epA.ep[i].field.current_eid != mctp_rt.epA.ep[i].field.default_eid)
        {
            mctp_rt.epA.ep[i].field.eid_type = MCTP_STATIC_DNEQC;
        }
    }

} /* End mctp_rtupdate_eid_type */

/******************************************************************************/
/** UPDATES EID_STATE FIELD OF RESPECTIVE ENDPOINT OF MCTP BRIDGE ROUTING TABLE
* @param i Endpoint entry id
* @return void
*******************************************************************************/
void mctp_rtupdate_eid_state(uint8_t i)
{
    trace1(0, MCTP, 0, "mctp_rtupd_eid_state: i = %Xh", i);

    if(mctp_rt.epA.ep[i].field.eid_type != MCTP_DYNAMIC_EID) /* means static */
    {
        mctp_rt.epA.ep[i].field.eid_state = MCTP_STATIC_ASSIGNED;
    }
    else if(mctp_rt.epA.ep[i].field.eid_type == MCTP_DYNAMIC_EID) /* means dynamic */
    {
        if(mctp_rt.epA.ep[i].field.current_eid == 0x00)
        {
            mctp_rt.epA.ep[i].field.eid_state = MCTP_DYNAMIC_NOTASSIGNED;
        }
        else
        {
            mctp_rt.epA.ep[i].field.eid_state = MCTP_DYNAMIC_ASSIGNED;
        }
    }

} /* End mctp_rtupdate_eid_state */

/******************************************************************************/
/** Initializes the mctp module.
* Mainly does initialization specific to mctp buffers, buffer parameters,
* variables and mctp-smbus/emi interface.
* @param void
* @return void
*******************************************************************************/
void mctp_init_task()
{
    trace0(0, MCTP, 0, "mctp_init_tsk: Enter");

    /* initialize mctp buffers */
    mctp_init_buffers();
    mctp_clean_up_buffer_states();

    /* initialization specific to smbus */
    //For data isolation - Register slave application function with smbus driver not required
    //smb_status = mctp_smbus_init();

    /* initialize mctp specific variables */
    mctp_tx_state = MCTP_TX_IDLE;
    mctp_txbuf_index = MCTP_BUF1; // Used for TX
    mctp_wait_smbus_callback = 0;

    mctp_cfg.smb_fairness = 1; /// Fairness enable
    mctp_cfg.mctp_discovery = false;
    mctp_cfg.smbus_speed = MCTP_I2C_CLK_FREQ; //default set to 400 Khz

} /* End mctp_init_task() */


void mctp_update_i2c_params(MCTP_CONTEXT* ret_mctp_ctxt)
{
    uint8_t i;
    uint8_t mctp_eid;
    if(NULL == ret_mctp_ctxt)
    {
        return;
    }
    mctp_cfg.smbus_speed = ret_mctp_ctxt->i2c_bus_freq;

    /* update mctp bridging routing table endpoint entries */
    for(i = 0; i < MCTP_ENDPOINTS_MAX; i++)
    {
        mctp_rtupdate_current_eid(i);
        mctp_rtupdate_eid_type(i);
        mctp_rtupdate_eid_state(i);
    }

    mctp_eid = ret_mctp_ctxt->eid;

    mctp_rt.epA.ep[MCTP_RT_EC_INDEX].field.default_eid = mctp_eid;
    mctp_rt.epA.ep[MCTP_RT_EC_INDEX].field.current_eid = mctp_eid;
    mctp_rtupdate_eid_type(MCTP_RT_EC_INDEX);
    mctp_rtupdate_eid_state(MCTP_RT_EC_INDEX);
}

/******************************************************************************/
/** Initializes mctp buffers.
* @param void
* @return void
*******************************************************************************/
void mctp_init_buffers(void)
{
    uint8_t i = 0;
    uint8_t j = 0;

    trace0(0, MCTP, 0, "mctp_init_bufs: Enter");

    for(i = 0; i < MCTP_PKT_BUF_NUM; i++)
    {
        for(j = 0; j < MCTP_PKT_BUF_DATALEN; j++)
        {
            mctp_pktbuf[i].pkt.data[j] = 0;
        }

        mctp_pktbuf[i].buf_full = MCTP_EMPTY;
        mctp_pktbuf[i].smbus_nack_retry_count = 0;
        mctp_pktbuf[i].smbus_acquire_retry_count = 0;
        mctp_pktbuf[i].smbus_lab_retry_count = 0;
        mctp_pktbuf[i].request_tx_retry_count = 0;
        mctp_pktbuf[i].request_per_tx_timeout_count = 0;
        mctp_pktbuf[i].rx_smbus_timestamp = 0;
    }

    trace0(0, MCTP, 0, "mctp_init_bufs: End");

} /* End mctp_init_buffers() */

/******************************************************************************/
/** This is called whenever kernel schedules mctp event task.
* Mctp module calls SET_MCTP_EVENT_TASK(mctp) for scheduling mctp event task.
* This event task is called whenever packet is received over smbus, or
* packet is to be transmitted over smbus.
* @param void
* @return void
*******************************************************************************/
void mctp_event_task(void)
{
    // Handling packet transmission over smbus
    mctp_event_tx_handler();

    // Handling packet received over smbus
    mctp_event_rx_handler();

} /* End mctp_event_task() */

/******************************************************************************/
/** mctp_event_tx_handler is called from mctp_event_task for handling
* packet transmission over smbus and to handle mctp tx state machine.
* @param void
* @return void
*******************************************************************************/
void mctp_event_tx_handler(void)
{
    uint8_t index = 0x00;
    uint32_t interval = 0;
    uint8_t hdr_struct_size = sizeof(MCTP_HEADER);

    MCTP_CONTEXT *mctpContext = NULL;
    mctpContext = mctp_ctxt_get();
    if(NULL == mctpContext)
    {
        return;
    }

    MCTP_PKT_BUF *tx_buf = MCTP_NULL;
    uint8_t acquire_status = 0x00;
    uint8_t pkt_type = 0;

    trace0(0, MCTP, 0, "mctp_evt_tx_hlr: Enter");

    switch(mctp_tx_state)
    {
    case MCTP_TX_IDLE:

        /* this will be only executed if there is mctp event set by rx;
         * nothing to be done here */

        trace0(0, MCTP, 0, "mctp_evt_tx_hlr: MCTP_TX_IDLE");

        break;

    case MCTP_TX_NEXT:

        trace0(0, MCTP, 0, "mctp_evt_tx_hlr: MCTP_TX_NEXT");

        for(index = 0; index < 5; index++)
        {
            /* check if that tx buffer is valid */
            if(MCTP_TX_PENDING == mctp_pktbuf[mctp_txbuf_index].buf_full)
            {
                trace0(0, MCTP, 0, "mctp_evt_tx_hlr: Pedng tx buf found");

                /* if TX buffer packet is response packet. As per the new spec,
                * check timing only for response packet from EC or MC*/
                if(mctp_txbuf_index == MCTP_BUF1 || mctp_txbuf_index == MCTP_BUF2 || mctp_txbuf_index == MCTP_BUF5)
                {
                    trace0(0, MCTP, 0, "mctp_evt_tx_hlr: ec tx rspse buf pendg");

                    /* get current TX buffer pointer */
                    tx_buf = (MCTP_PKT_BUF *)&mctp_pktbuf[mctp_txbuf_index];
                    memset(&transmit_buf[0], 0, sizeof(MCTP_BUFDATA));

                    if (tx_buf->pkt.field.hdr.som == true)
                    {
                        store_msg_type_tx = tx_buf->pkt.field.hdr.msg_type;
                    }
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
                    if(store_msg_type_tx == MCTP_MSGTYPE_SPDM)
                    {
                        memcpy(&transmit_buf[0], (uint8_t *)&tx_buf->pkt.data[MCTP_PKT_DST_ADDR_POS], (hdr_struct_size - 1));
                        memcpy(&transmit_buf[hdr_struct_size-1], (uint8_t *)&tx_buf->pkt.data[MCTP_PKT_RQ_D_POS],
                               (MCTP_PKT_BUF_DATALEN - (hdr_struct_size - 1)));
                        memcpy(&tx_buf->pkt.data[0], (uint8_t *)&transmit_buf[0], sizeof(MCTP_BUFDATA));
                    }
                    else
</#if>
                    {
                        memcpy(&transmit_buf[0], (uint8_t *)&tx_buf->pkt.data[MCTP_PKT_DST_ADDR_POS], hdr_struct_size);
                        memcpy(&transmit_buf[hdr_struct_size], (uint8_t *)&tx_buf->pkt.data[10], (MCTP_PKT_BUF_DATALEN - (hdr_struct_size)));
                        memcpy(&tx_buf->pkt.data[0], (uint8_t *)&transmit_buf[0], sizeof(MCTP_BUFDATA));
                    }
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
                    //if spdm message with get certificate command, no timeout specified as per spec
                   if((store_msg_type_tx == MCTP_MSGTYPE_SPDM) && (mctpContext->check_spdm_cmd == MCTP_SPDM_CMD_GET_CERT))
                   {
                       /* change state to transmit it's data over smbus */
                       mctp_tx_state = MCTP_TX_SMBUS_ACQUIRE;
                   }
                   else
</#if>
                    {
                        /* check timeout condition */
                       if(!mctp_tx_timeout(tx_buf))
                        {
                            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: rspse 132ms");

                            /* change state to transmit it's data over smbus */
                            mctp_tx_state = MCTP_TX_SMBUS_ACQUIRE;

                            /*Process the non empty buffer*/
                            /*This break comes out of "for" loop*/
                            break;
                        }
                        /* if 135ms timeout */
                        else
                        {
                            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: respse after 100ms");

                            /* drop packet, free that buffer */
                            mctp_smbdone_drop(tx_buf);

                            /* for indexing to next tx buffer */
                            mctp_txbuf_index++;

                            /* since tx buffers ranges from MCTP_BUF1 to MCTP_BUF5 */
                            if(mctp_txbuf_index > MCTP_BUF5)
                            {
                                mctp_txbuf_index = MCTP_BUF1;
                            }
                        }
                    }
                }
                /* if other than ec tx response buffer; */
                /* then no need to check 100ms timeout condition */
                else
                {
                    trace0(0, MCTP, 0, "mctp_evt_tx_hlr: ec tx respse bufr");

                    /* change state to transmit it's data over smbus */
                    mctp_tx_state = MCTP_TX_SMBUS_ACQUIRE;

                    start_time = (uint32_t)(mctp_i2c_get_current_timestamp());
                    // interval = 0; // Coverity security Fixes, variable unused
                    /*Process the non empty buffer*/
                    /*This break comes out of "for" loop*/
                    break;
                }
            }
            else
            {
                trace0(0, MCTP, 0, "mctp_evt_tx_hlr: idexng next tx bufr");

                /* for indexing to next tx buffer */
                mctp_txbuf_index++;

                /* since tx buffers ranges from MCTP_BUF1 to MCTP_BUF2 */
                if(mctp_txbuf_index > MCTP_BUF5)
                {
                    mctp_txbuf_index = MCTP_BUF1;
                }
            }
        }
        /* if no valid TX buffer is found */
        if(mctp_tx_state == MCTP_TX_NEXT)
        {
            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: no pndng tx bufr found");

            /* change mctp tx state to idle */
            mctp_tx_state = MCTP_TX_IDLE;

            /* initialize to start with MCTP_BUF1; */
            mctp_txbuf_index = MCTP_BUF1;

            /*This break ends switch case*/
            break;
        }
    /*If code reaches here, one or more TX buffers are active. So
     * fall-through to next state*/

    case MCTP_TX_SMBUS_ACQUIRE:

        trace0(0, MCTP, 0, "mctp_evt_tx_hlr: MCTP_TX_SMBUS_ACQUIRE");

        /*Check if smbus can be acquired. We are not running preemptive
         * kernel. So status check and bus usage following that, are atomic
         * in nature*/
        acquire_status = mctp_i2c_get_chan_busy_status(MCTP_I2C_CHANNEL);

        /* get current TX buffer pointer */
        tx_buf = (MCTP_PKT_BUF *)&mctp_pktbuf[mctp_txbuf_index];

        if(I2C_MASTER_AVAILABLE == acquire_status)
        {
            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: I2C_MASTER_AVAILABLE");

            /*smbus is available, start transmission*/
            mctp_wait_smbus_callback = 0x0;

            mctp_tx_state = MCTP_TX_IN_PROGRESS;
            /*Fall Through to MCTP_TX_IN_PROGRESS state*/
        }
        else if(I2C_MASTER_BUSY == acquire_status)
        {
            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: I2C_MASTER_BUSY");


            interval = mctp_timer_difference(start_time);

            if(interval >= (uint32_t) MCTP_SMBUS_AQ_TIMEOUT )//135000 = 135ms
            {
                trace0(0, MCTP, 0, "mctp_evt_tx_hlr: SB mstr busy retry cnt exhstd");

                /* update buffer parameters and configure events */
                mctp_smbdone_handler(tx_buf);

                mctp_tx_state = MCTP_TX_NEXT;

            }
            else
            {
                mctp_tx_state = MCTP_TX_SMBUS_ACQUIRE;
            }

            SET_MCTP_EVENT_TASK(mctp);

            /*Exit switch case*/
            break;
        }
    /*Fall thorugh to the next state MCTP_TX_IN_PROGRESS*/

    case MCTP_TX_IN_PROGRESS:

        trace0(0, MCTP, 0, "mctp_evt_tx_hlr: MCTP_TX_IN_PROGRESS");

        if(0x0 == mctp_wait_smbus_callback)
        {
            mctp_wait_smbus_callback = 1;

            trace0(0, MCTP, 0, "mctp_evt_tx_hlr: init tx SB");

            mctp_transmit_smbus(tx_buf);
        }
        break;

    default:

        trace0(0, MCTP, 0, "mctp_evt_tx_hlr: default");

        break;
    }
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
    if ((mctp_pktbuf[mctp_txbuf_index].pkt.data[PLDM_HEADER_VERSION_PLDM_TYPE_POS] == PLDM_TYPE5_AND_HEADER_VERSION)
            && (mctp_pktbuf[mctp_txbuf_index].pkt.data[PLDM_HEADER_COMMAND_CODE_POS] == PLDM_SEND_VERIFY_COMPLETE_CMD))
    {
        mctp_pktbuf[mctp_txbuf_index].buf_full = MCTP_EMPTY;
    }
</#if>
    trace0(0, MCTP, 0, "mctp_evt_tx_hlr: End");

} /* End mctp_event_tx_handler() */

/******************************************************************************/
/** mctp_event_rx_handler is called from mctp_event_task for handling
* packet received over smbus.
* @param void
* @return void
*******************************************************************************/
void mctp_event_rx_handler(void)
{
    trace0(0, MCTP, 0, "mctp_evt_rx_hlr: Enter");

    // EC RX REQUEST HANDLER - checks if EC RX REQUEST pkt is pending, and processes it.
    mctp_handle_ec_rx_request_pkt();

} /* End mctp_event_rx_handler() */

/******************************************************************************/
/** EC RX REQUEST HANDLER - checks if EC RX REQUEST pkt is pending, and processes it.
* @param void
* @return void
*******************************************************************************/
void mctp_handle_ec_rx_request_pkt(void)
{
    MCTP_PKT_BUF *rx_buf;
    MCTP_PKT_BUF *tx_resp_buf;
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
    MCTP_PKT_BUF *spdm_msg_rx_buf;
</#if>
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
    MCTP_PKT_BUF *pldm_msg_rx_buf;
</#if>

    trace0(0, MCTP, 0, "mctp_handle_ec_rx_rqst_pkt: Enter");

    /* get pointer of ec rx request buffer */
    rx_buf      = (MCTP_PKT_BUF *) &mctp_pktbuf[MCTP_BUF1];
    /* get pointer of ec tx response buffer */
    tx_resp_buf = (MCTP_PKT_BUF *) &mctp_pktbuf[MCTP_BUF1];
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
    /* get pointer of ec response buffer for spdm*/
    spdm_msg_rx_buf = (MCTP_PKT_BUF *) &mctp_pktbuf[MCTP_BUF3];
</#if>

<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
    pldm_msg_rx_buf = (MCTP_PKT_BUF *) &mctp_pktbuf[MCTP_BUF4];
</#if>
    /* if ec rx request buffer has valid packet */
    if(rx_buf->buf_full == MCTP_RX_PENDING)
    {
        trace0(0, MCTP, 0, "mctp_hdle_ec_rx_rqst_pkt: ec rx rqst bufr vld pkt");

        /* if packet type is control */
        if(rx_buf->pkt.field.hdr.msg_type == MCTP_MSGTYPE_CONTROL)
        {
            /// There will be a message availabe for the control message type eithe Valid or error
            trace0(0, MCTP, 0, "mctp_hdle_ec_rx_rqst_pkt: pkt type ctrl");
            if((0 == mctp_rt.ep.mc.field.current_eid )|| ( 0 == mctp_rt.ep.mc.field.smb_address))
            {
                mctp_rt.ep.mc.field.current_eid = rx_buf->pkt.field.hdr.src_eid;
                mctp_rt.ep.mc.field.smb_address = rx_buf->pkt.field.hdr.src_addr;
            }

            mctp_ec_control_pkt_handler(rx_buf, tx_resp_buf);
            mctp_txpktready_init(tx_resp_buf);
        }
    }
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
    else if(spdm_msg_rx_buf->buf_full == MCTP_RX_PENDING)
    {
        spdm_msg_rx_buf->buf_full = MCTP_EMPTY;//MCTP receive buffer for spdm available
        memset(spdm_msg_rx_buf, 0, MCTP_PKT_BUF_DATALEN);
    }
</#if>
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
    else if (pldm_msg_rx_buf->buf_full == MCTP_RX_PENDING)
    {
        pldm_msg_rx_buf->buf_full = MCTP_EMPTY;
        memset(pldm_msg_rx_buf, 0, MCTP_PKT_BUF_DATALEN);
    }
</#if>
} /* mctp_handle_ec_rx_request_pkt */

/******************************************************************************/
/** Validates packet received over smbus.
* @param *pktbuf Pointer to smbus layer packet buffer
* @return MCTP_TRUE if packet is found valid, else return MCTP_FALSE
*******************************************************************************/
uint8_t mctp_packet_validation(uint8_t *pkt_buf)
{
    uint8_t buf_size = 0x00;
    uint8_t iter = 0x00;
    trace0(0, MCTP, 0, "mctp pkt val:Etr");

    //Check this checking
    if (!((pkt_buf[MCTP_PKT_BYTE_CNT_POS] >= MCTP_BYTECNT_MIN) &&
            (pkt_buf[MCTP_PKT_BYTE_CNT_POS] <= MCTP_BYTECNT_MAX)))
    {
        trace0(0, MCTP, 0, "mctp pkt val:Ivld Byte Cnt");
        return MCTP_FALSE;
    }

    if (pkt_buf[MCTP_PKT_HDR_VER_POS] != MCTP_HDR_VER_REF)
    {
        trace0(0, MCTP, 0, "mctp pkt val:Ivld Rsvd/Hdr Ver");
        return MCTP_FALSE;
    }

    if (((pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_SOM_EOM_REF_MSK) == MCTP_SOM_EOM_REF) && (packetizing == false))
    {
        if (!((pkt_buf[MCTP_PKT_DST_EID_POS] == mctp_rt.ep.ec.field.current_eid) ||
                (pkt_buf[MCTP_PKT_DST_EID_POS] == MCTP_NULL_EID)))
        {
            trace0(0, MCTP, 0, "mctp pkt val:Ivld Dst EID Cntrl Msg");
            return MCTP_FALSE;
        }
        if (MCTP_OTHER_PKT == mctp_get_packet_type(pkt_buf)
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
                && (pkt_buf[MCTP_PKT_IC_MSGTYPE_POS] != MCTP_IC_MSGTYPE_SPDM) /* Check not required for SPDM */
</#if>
                )
        {
            trace0(0, MCTP, 0, "mctp pkt val:Pkt neither req nor resp");
            return MCTP_FALSE;
        }
        mctp_self.message_type = pkt_buf[MCTP_PKT_IC_MSGTYPE_POS];
    }

    //if SOM == 1, EOM == 0 || SOM == 0, EOM == 0 || SOM == 0 , EOM == 1
    else if (!((pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_SOM_EOM_REF_MSK) == MCTP_SOM_EOM_REF))
    {
        if (!((pkt_buf[MCTP_PKT_DST_EID_POS] == mctp_rt.ep.ec.field.current_eid) ||
                (pkt_buf[MCTP_PKT_DST_EID_POS] == MCTP_NULL_EID)))
        {
            trace0(0, MCTP, 0, "mctp pkt val:Ivld Dst EID Ctl Msg");
            return MCTP_FALSE;
        }

        if( (pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_SOM_REF_MSK) == MCTP_SOM_REF ) // IF SOM ==1
        {
            if (MCTP_OTHER_PKT == mctp_get_packet_type(pkt_buf)
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
                    && (pkt_buf[MCTP_PKT_IC_MSGTYPE_POS] != MCTP_IC_MSGTYPE_SPDM) /* Check not required for SPDM */
</#if>
                    )
            {
                trace0(0, MCTP, 0, "mctp pkt val:Mul pkt neither req nor resp");
                return MCTP_FALSE;
            }
        }

        if( (pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_SOM_REF_MSK) == MCTP_SOM_REF ) // IF SOM ==1
        {
            store_msg_tag = pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_MSG_TAG_REF_MASK;
            store_msg_type_state = pkt_buf[MCTP_PKT_IC_MSGTYPE_POS];
            pkt_seq_num = 0;
            out_of_seq_detected = false;
        }
        else if ((pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_MSG_TAG_REF_MASK) != store_msg_tag)
        {
            trace0(0, MCTP, 0, "mctp pkt val:Msg Tag Mismatch");
            return MCTP_FALSE;
        }

        if (out_of_seq_detected)
        {
            trace0(0, MCTP, 1, "mctp pkt val:Out of seq, dropng msg");
            return MCTP_FALSE;
        }

        if (!(((pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_MSG_PKSEQ_REF_MASK) >> MCTP_MSG_PKSEQ_SHIFT) == pkt_seq_num))
        {
            trace0(0, MCTP, 1, "mctp pkt val:Pkt Seq Msmth");
            out_of_seq_detected = true;
            return MCTP_FALSE;
        }
        pkt_seq_num += INCR_NEXT;
        pkt_seq_num = (pkt_seq_num & MCTP_MSG_PKSEQ_MAX_MASK); // pkt seq num can take max 2 bits

        if( (pkt_buf[MCTP_PKT_TO_MSGTAG_POS] & MCTP_EOM_REF_MSK) == MCTP_EOM_REF )
        {
            pkt_seq_num = 0;
            out_of_seq_detected = false;
        }

        mctp_base_packetizing_val_set(true);
        mctp_self.message_type = store_msg_type_state;
    }
    else
    {
        trace0(0, MCTP, 0, "mctp pkt val:Ivld Pkt");
        trace1(0, MCTP, 0, "Packet 7 MCTP_SOM_EOM_REF     = 0x%X ; ", pkt_buf[MCTP_PKT_TO_MSGTAG_POS]);
        trace1(0, MCTP, 0, "Packet 8 MCTP_IC_MSGTYPE_VNDR = 0x%X ; ", pkt_buf[MCTP_PKT_IC_MSGTYPE_POS]);
        mctp_base_packetizing_val_set(false);
        return MCTP_FALSE;
    }

    trace0(0, MCTP, 0, "mctp pkt val:Pkt fnd vld");

    return MCTP_TRUE;

} /* End mctp_packet_validation() */

/******************************************************************************/
/** For response TX packet buffer, this compares current time with initial
* reference time (when corresponding request packet was received over smbus)
* to check 135ms timeout condition.
* @param *tx_buf Pointer to TX response packet buffer
* @return MCTP_TRUE if trasmission timeout, else return MCTP_FALSE
*******************************************************************************/
uint8_t mctp_tx_timeout(MCTP_PKT_BUF *tx_buf)
{
    uint16_t processing_time;

    uint16_t max_tick_count = 0x00;

    trace0(0, MCTP, 0, "mctp_tx_TO: nter");

    /* get current request_per_tx_timeout_count */
    processing_time = mctp_timer_difference(tx_buf->rx_smbus_timestamp);

    trace1(0, MCTP, 0, "mctp_tx_TO: proc_time = %04Xh", processing_time);

    if (store_msg_type_tx == MCTP_MSGTYPE_CONTROL)
    {
        max_tick_count = ((MCTP_TIMEOUT_MS * configTICK_RATE_HZ)/1000); //max 100 ms timeout
    }
<#if MCTP_IS_SPDM_COMPONENT_CONNECTED == true>
    if (store_msg_type_tx == MCTP_MSGTYPE_SPDM)// SPDM Message
    {
        max_tick_count = ((SPDM_TIMEOUT_MS * configTICK_RATE_HZ)/1000); //max 135 ms timeout
    }
</#if>
<#if MCTP_IS_PLDM_COMPONENT_CONNECTED == true>
    if (store_msg_type_tx == MCTP_MSGTYPE_PLDM)
    {
        return MCTP_FALSE;
    }
</#if>
    /* check for timeout condition */
    if(processing_time <= max_tick_count)
    {
        trace0(0, MCTP, 0, "mctp_tx_TO: rspse 135ms");

        return MCTP_FALSE;
    }
    else
    {
        trace0(0, MCTP, 0, "mctp_tx_TO: rspse after 135ms");

        return MCTP_TRUE;
    }

} /* End mctp_tx_timeout() */

/******************************************************************************/
/** For Calculating the time difference between current and the time given
* @param start_time Start time counter value
* @return Return the difference between start and end timing
*******************************************************************************/
uint32_t mctp_timer_difference(uint32_t start_time)
{
    uint32_t interval;

    /* get current time interval */
    interval = (uint32_t)(mctp_i2c_get_current_timestamp());

    if(interval >= start_time)
    {
        interval = (interval - start_time);
    }
    else
    {
        interval = ((0xFFFFFFFF - start_time) + interval);
    }

    return interval;
}

/******************************************************************************/
/** Get packet type - response or request or other.
* @param *buffer_ptr Pointer to packet buffer
* @return Packet type - request, response or other.
*******************************************************************************/
uint8_t mctp_get_packet_type(uint8_t *buffer_ptr)
{
    uint8_t tag_owner_field;
    uint8_t req_field;
    uint8_t dtgram_field;

    trace0(0, MCTP, 0, "mctp_get_pkt_type: nter");

    tag_owner_field = (buffer_ptr[MCTP_PKT_TO_MSGTAG_POS] & MCTP_HDR_MASK_TO) >> 3;
    req_field       = (buffer_ptr[MCTP_PKT_RQ_D_POS] & MCTP_HDR_MASK_RQ) >> 7;
    dtgram_field    = (buffer_ptr[MCTP_PKT_RQ_D_POS] & MCTP_HDR_MASK_D) >> 6;

    /* if request packet */
    if((tag_owner_field == 1) && (req_field == 1) && (dtgram_field == 0))
    {
        trace0(0, MCTP, 0, "mctp_get_pkt_type: rqt pkt");

        return MCTP_REQ_PKT;
    }    /* else if response packet */
    else if((tag_owner_field == 0) && (req_field == 0) && (dtgram_field == 0))
    {
        trace0(0, MCTP, 0, "mctp_get_pkt_type: rspse pkt");

        return MCTP_RESP_PKT;
    }
    /* else neither request nor response */
    else
    {
        trace0(0, MCTP, 0, "mctp_get_pkt_type: other pkt");

        return MCTP_OTHER_PKT;
    }

} /* End mctp_get_packet_type */

/**   @}
 */

