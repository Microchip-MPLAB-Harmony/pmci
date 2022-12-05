# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""
def destroyComponent(spdmCoreComponent):
    Database.sendMessage("MCTP", "SPDM_CONNECTED", {"isConnected":False})
    
    
def instantiateComponent(spdmCoreComponent):
    print("OCP SPDM core component initialize")
    
    autoComponentIDTable = ["MCTP"]
    
    spdmCoreComponent.addDependency("MCTP_DEP", "MCTP", None, True, True)
    spdmCoreComponent.setDependencyEnabled("MCTP_DEP", True)
    Database.activateComponents(autoComponentIDTable)
    
    Database.sendMessage("MCTP", "SPDM_CONNECTED", {"isConnected":True})
    
    #Add configuration files to project
    #Add mctp_config.h
    spdmConfigHeaderFtl = spdmCoreComponent.createFileSymbol(None, None)
    spdmConfigHeaderFtl.setSourcePath("stack/spdm/src/config/spdm_config.h.ftl")
    spdmConfigHeaderFtl.setOutputName("spdm_config.h")
    spdmConfigHeaderFtl.setDestPath("../../dmtf/spdm/config/")
    spdmConfigHeaderFtl.setProjectPath("spdm/config/")
    spdmConfigHeaderFtl.setOverwrite(True)
    spdmConfigHeaderFtl.setType("HEADER")
    spdmConfigHeaderFtl.setMarkup(True)
    
    #Add interface files to project
    #Add spdm_iface.h
    spdmIfaceHeaderFile = spdmCoreComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("stack/spdm/src/interface/spdm_iface.h")
    spdmIfaceHeaderFile.setOutputName("spdm_iface.h")
    spdmIfaceHeaderFile.setDestPath("../../dmtf/spdm/interface/")
    spdmIfaceHeaderFile.setProjectPath("spdm/interface/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)
    #Add spdm_iface.c
    spdmIfaceSourceFile = spdmCoreComponent.createFileSymbol(None, None)
    spdmIfaceSourceFile.setSourcePath("stack/spdm/src/interface/spdm_iface.c")
    spdmIfaceSourceFile.setOutputName("spdm_iface.c")
    spdmIfaceSourceFile.setDestPath("../../dmtf/spdm/interface/")
    spdmIfaceSourceFile.setProjectPath("spdm/interface/")
    spdmIfaceSourceFile.setOverwrite(True)
    spdmIfaceSourceFile.setType("SOURCE")
    spdmIfaceSourceFile.setMarkup(False)
    
    #Add core files
    #Add spdm_pkt_prcs.h
    spdmIfaceHeaderFile = spdmCoreComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("stack/spdm/src/core/spdm_pkt_prcs.h")
    spdmIfaceHeaderFile.setOutputName("spdm_pkt_prcs.h")
    spdmIfaceHeaderFile.setDestPath("../../dmtf/spdm/core/")
    spdmIfaceHeaderFile.setProjectPath("spdm/core/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)
    
    #Add spdm_pkt_prcs.c
    spdmIfaceSourceFile = spdmCoreComponent.createFileSymbol(None, None)
    spdmIfaceSourceFile.setSourcePath("stack/spdm/src/core/spdm_pkt_prcs.c")
    spdmIfaceSourceFile.setOutputName("spdm_pkt_prcs.c")
    spdmIfaceSourceFile.setDestPath("../../dmtf/spdm/core/")
    spdmIfaceSourceFile.setProjectPath("spdm/core/")
    spdmIfaceSourceFile.setOverwrite(True)
    spdmIfaceSourceFile.setType("SOURCE")
    spdmIfaceSourceFile.setMarkup(False)