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

#include "spt_app.h"
#include "FreeRTOS.h"
#include "task.h"
#include "spt/spt_task.h"


uint8_t spt_register_slave(uint8_t channel, SPT_SLAVE_FUNC_PTR slaveFuncPtr)
{
    spt_register_app_rx_callback(channel, slaveFuncPtr);
}

uint16_t spt_get_current_timestamp(void) {
    return (uint16_t) (xTaskGetTickCount() / 10);
 
}

void spt_channel_enable(uint8_t channel, uint8_t io_mode, uint8_t spt_wait_time,
        uint8_t tar_time)
{
    SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(channel);
    if(NULL != sptContext)
    {
        sptContext->io_mode = io_mode;
        sptContext->tar_time =tar_time;
        sptContext->wait_time = spt_wait_time;
        if(channel)
        {
            spt_set_event_bits(SPT1_ENABLE_BIT);
        }
        else
        {
            spt_set_event_bits(SPT0_ENABLE_BIT);
        }
    }
}

void spt_channel_disable(uint8_t channel)
{
    if(channel)
    {
        spt_set_event_bits(SPT1_DISABLE_BIT);
    }
    else
    {
        spt_set_event_bits(SPT0_DISABLE_BIT);
    }
}

uint8_t spt_tx(uint8_t channel, uint8_t* buff_ptr, uint16_t writecount, uint8_t pecEnable, TX_FUNC_PTR func_ptr)
{
    SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(channel);
    if(NULL != sptContext)
    {
        sptContext->txappbuff_ptr = buff_ptr;
        sptContext->writecount = writecount;
        sptContext->pecEnable = pecEnable;
        sptContext->txfunc_ptr = func_ptr;
                
        if(channel)
        {
            spt_set_event_bits(SPT1_TRANSMIT_REQUEST_BIT);
        }
        else
        {
            spt_set_event_bits(SPT0_TRANSMIT_REQUEST_BIT);
        }
        return 0;
    }  
}

uint8_t spt_tx_done_callback(uint8_t channel, uint8_t status, TX_FUNC_PTR func_ptr, uint8_t* app_buff)
{
    if(NULL != func_ptr)
    {
        func_ptr(channel, status, app_buff, NULL);
    }
}

void spt_event_handle(EventBits_t uxBits)
{
    if((SPT_EVENT_BIT == (uxBits & SPT_EVENT_BIT)) || (SPT_ISR_EVENT_BIT == (uxBits & SPT_ISR_EVENT_BIT)))
    {
        spt_read_event_handler();
        spt_write_event_handler();
    }
    if(SPT1_ENABLE_BIT == (uxBits & SPT1_ENABLE_BIT))
    {  
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT1);
        if(NULL != sptContext)
        {
            (void)spt_config_and_enable(SPT1, sptContext->io_mode,
                    sptContext->wait_time, sptContext->tar_time);
        }
    }
    if(SPT0_ENABLE_BIT == (uxBits & SPT0_ENABLE_BIT))
    {  
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT0);
        if(NULL != sptContext)
        {
            (void)spt_config_and_enable(SPT0, sptContext->io_mode,
                    sptContext->wait_time, sptContext->tar_time);
        }
    }
    if(SPT1_DISABLE_BIT == (uxBits & SPT1_DISABLE_BIT))
    {
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT1);
        if(NULL != sptContext)
        {
                spt_disable(SPT1);
        }
    }
    if(SPT0_DISABLE_BIT == (uxBits & SPT0_DISABLE_BIT))
    {
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT0);
        if(NULL != sptContext)
        {
                spt_disable(SPT0);
        }
    }
    if(SPT0_TRANSMIT_REQUEST_BIT == (uxBits & SPT0_TRANSMIT_REQUEST_BIT))
    {
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT0);
        if(NULL != sptContext)
        {
            (void)spt_write(SPT0, sptContext->txappbuff_ptr, 
                       sptContext->writecount, sptContext->pecEnable,
                       sptContext->txfunc_ptr);
        }
    }
    if(SPT1_TRANSMIT_REQUEST_BIT == (uxBits & SPT1_TRANSMIT_REQUEST_BIT))
    {
        SPT_CONTEXT_PER_CHANNEL* sptContext = spt_channel_ctxt_get(SPT1);
        if(NULL != sptContext)
        {
            (void)spt_write(SPT1, sptContext->txappbuff_ptr, 
                       sptContext->writecount, sptContext->pecEnable,
                       sptContext->txfunc_ptr);
        }
    }
}

void spt_raise_interrrupt_event()
{
    spt_set_event_bits_isr(SPT_ISR_EVENT_BIT);
}

void spt_event_trigger()
{
    spt_set_event_bits(SPT_EVENT_BIT);
}
