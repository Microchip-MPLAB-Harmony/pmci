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
    Database.sendMessage("sg3_src", "SPDM_CONNECTED", {"isConnected":False})
    Database.sendMessage("sg3_lib", "SPDM_CONNECTED", {"isConnected":False})

def handleMessage(messageID, args):
    global isSoteriaComponentConnected

    if(messageID == "SOTERIA_CONNECTED"):
        if(args.get("isConnected") == True):
            isSoteriaComponentConnected.setValue(True)
        else:
            isSoteriaComponentConnected.setValue(False)


def instantiateComponent(spdmComponent):
    global isSoteriaComponentConnected
    print("SPDM stack component initialize")
    
    autoComponentIDTable = ["MCTP"]
    
    # MCTP is required for SPDM module to function
    spdmComponent.addDependency("MCTP_DEP", "MCTP", None, True, True)
    spdmComponent.setDependencyEnabled("MCTP_DEP", True)
    Database.activateComponents(autoComponentIDTable)
    
    Database.sendMessage("MCTP", "SPDM_CONNECTED", {"isConnected":True})
    Database.sendMessage("sg3_src", "SPDM_CONNECTED", {"isConnected":True})
    Database.sendMessage("sg3_lib", "SPDM_CONNECTED", {"isConnected":True})

    spdmCertChainSlot01 = spdmComponent.createHexSymbol("SPDM_CERT_CHAIN_SLOT_01", None)
    spdmCertChainSlot01.setLabel("Slot 01 Certificate Chain")
    spdmCertChainSlot01.setDescription("Slot 01 Certificate Chain value")
    spdmCertChainSlot01.setDefaultValue(0x88)
    spdmCertChainSlot01.setVisible(True)

    spdmCertChainSlot23 = spdmComponent.createHexSymbol("SPDM_CERT_CHAIN_SLOT_23", None)
    spdmCertChainSlot23.setLabel("Slot 23 Certificate Chain")
    spdmCertChainSlot23.setDescription("Slot 23 Certificate Chain value")
    spdmCertChainSlot23.setDefaultValue(0x88)
    spdmCertChainSlot23.setVisible(True)

    spdmCertChainSlot45 = spdmComponent.createHexSymbol("SPDM_CERT_CHAIN_SLOT_45", None)
    spdmCertChainSlot45.setLabel("Slot 45 Certificate Chain")
    spdmCertChainSlot45.setDescription("Slot 45 Certificate Chain value")
    spdmCertChainSlot45.setDefaultValue(0x88)
    spdmCertChainSlot45.setVisible(True)

    spdmCertChainSlot67 = spdmComponent.createHexSymbol("SPDM_CERT_CHAIN_SLOT_67", None)
    spdmCertChainSlot67.setLabel("Slot 67 Certificate Chain")
    spdmCertChainSlot67.setDescription("Slot 67 Certificate Chain value")
    spdmCertChainSlot67.setDefaultValue(0x88)
    spdmCertChainSlot67.setVisible(True)

    # head pointer
    spdmHeadPointer0 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_0", None)
    spdmHeadPointer0.setLabel("Head Pointer 0")
    spdmHeadPointer0.setDescription("Head Pointer 0 value")
    spdmHeadPointer0.setDefaultValue(0x40)
    spdmHeadPointer0.setVisible(True)

    spdmHeadPointer1 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_1", None)
    spdmHeadPointer1.setLabel("Head Pointer 1")
    spdmHeadPointer1.setDescription("Head Pointer 1 value")
    spdmHeadPointer1.setDefaultValue(0x40)
    spdmHeadPointer1.setVisible(True)

    spdmHeadPointer2 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_2", None)
    spdmHeadPointer2.setLabel("Head Pointer 2")
    spdmHeadPointer2.setDescription("Head Pointer 2 value")
    spdmHeadPointer2.setDefaultValue(0x40)
    spdmHeadPointer2.setVisible(True)

    spdmHeadPointer3 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_3", None)
    spdmHeadPointer3.setLabel("Head Pointer 3")
    spdmHeadPointer3.setDescription("Head Pointer 3 value")
    spdmHeadPointer3.setDefaultValue(0x40)
    spdmHeadPointer3.setVisible(True)

    spdmHeadPointer4 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_4", None)
    spdmHeadPointer4.setLabel("Head Pointer 4")
    spdmHeadPointer4.setDescription("Head Pointer 4 value")
    spdmHeadPointer4.setDefaultValue(0x40)
    spdmHeadPointer4.setVisible(True)

    spdmHeadPointer5 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_5", None)
    spdmHeadPointer5.setLabel("Head Pointer 5")
    spdmHeadPointer5.setDescription("Head Pointer 5 value")
    spdmHeadPointer5.setDefaultValue(0x40)
    spdmHeadPointer5.setVisible(True)

    spdmHeadPointer6 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_6", None)
    spdmHeadPointer6.setLabel("Head Pointer 6")
    spdmHeadPointer6.setDescription("Head Pointer 6 value")
    spdmHeadPointer6.setDefaultValue(0x40)
    spdmHeadPointer6.setVisible(True)

    spdmHeadPointer7 = spdmComponent.createHexSymbol("SPDM_HEAD_POINTER_7", None)
    spdmHeadPointer7.setLabel("Head Pointer 7")
    spdmHeadPointer7.setDescription("Head Pointer 7 value")
    spdmHeadPointer7.setDefaultValue(0x40)
    spdmHeadPointer7.setVisible(True)

    # tail pointer
    spdmTailPointerCertificate0123 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE0123", None)
    spdmTailPointerCertificate0123.setLabel("Tail pointer for Certificate 0,1,2,3")
    spdmTailPointerCertificate0123.setDescription("Tail pointer for Certificate 0,1,2,3")
    spdmTailPointerCertificate0123.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate0123.setVisible(True)

    spdmTailPointerCertificate4567 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE4567", None)
    spdmTailPointerCertificate4567.setLabel("Tail pointer for Certificate 4,5,6,7")
    spdmTailPointerCertificate4567.setDescription("Tail pointer for Certificate 4,5,6,7")
    spdmTailPointerCertificate4567.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate4567.setVisible(True)

    spdmTailPointerCertificate891011 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE891011", None)
    spdmTailPointerCertificate891011.setLabel("Tail pointer for Certificate 8,9,10,11")
    spdmTailPointerCertificate891011.setDescription("Tail pointer for Certificate 8,9,10,11")
    spdmTailPointerCertificate891011.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate891011.setVisible(True)

    spdmTailPointerCertificate12131415 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE12131415", None)
    spdmTailPointerCertificate12131415.setLabel("Tail pointer for Certificate 12,13,14,15")
    spdmTailPointerCertificate12131415.setDescription("Tail pointer for Certificate 12,13,14,15")
    spdmTailPointerCertificate12131415.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate12131415.setVisible(True)

    spdmTailPointerCertificate16171819 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE16171819", None)
    spdmTailPointerCertificate16171819.setLabel("Tail pointer for Certificate 16,17,18,19")
    spdmTailPointerCertificate16171819.setDescription("Tail pointer for Certificate 16,17,18,19")
    spdmTailPointerCertificate16171819.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate16171819.setVisible(True)

    spdmTailPointerCertificate20212223 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE20212223", None)
    spdmTailPointerCertificate20212223.setLabel("Tail pointer for Certificate 20,21,22,23")
    spdmTailPointerCertificate20212223.setDescription("Tail pointer for Certificate 20,21,22,23")
    spdmTailPointerCertificate20212223.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate20212223.setVisible(True)

    spdmTailPointerCertificate24252627 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE24252627", None)
    spdmTailPointerCertificate24252627.setLabel("Tail pointer for Certificate 24,25,26,27")
    spdmTailPointerCertificate24252627.setDescription("Tail pointer for Certificate 24,25,26,27")
    spdmTailPointerCertificate24252627.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate24252627.setVisible(True)

    spdmTailPointerCertificate28293031 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE28293031", None)
    spdmTailPointerCertificate28293031.setLabel("Tail pointer for Certificate 28,29,30,31")
    spdmTailPointerCertificate28293031.setDescription("Tail pointer for Certificate 28,29,30,31")
    spdmTailPointerCertificate28293031.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate28293031.setVisible(True)

    spdmTailPointerCertificate32333435 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE32333435", None)
    spdmTailPointerCertificate32333435.setLabel("Tail pointer for Certificate 32,33,34,35")
    spdmTailPointerCertificate32333435.setDescription("Tail pointer for Certificate 32,33,34,35")
    spdmTailPointerCertificate32333435.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate32333435.setVisible(True)

    spdmTailPointerCertificate36373839 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE36373839", None)
    spdmTailPointerCertificate36373839.setLabel("Tail pointer for Certificate 36,37,38,39")
    spdmTailPointerCertificate36373839.setDescription("Tail pointer for Certificate 36,37,38,39")
    spdmTailPointerCertificate36373839.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate36373839.setVisible(True)

    spdmTailPointerCertificate40414243 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE40414243", None)
    spdmTailPointerCertificate40414243.setLabel("Tail pointer for Certificate 40,41,42,43")
    spdmTailPointerCertificate40414243.setDescription("Tail pointer for Certificate 40,41,42,43")
    spdmTailPointerCertificate40414243.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate40414243.setVisible(True)

    spdmTailPointerCertificate44454647 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE44454647", None)
    spdmTailPointerCertificate44454647.setLabel("Tail pointer for Certificate 44,45,46,47")
    spdmTailPointerCertificate44454647.setDescription("Tail pointer for Certificate 44,45,46,47")
    spdmTailPointerCertificate44454647.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate44454647.setVisible(True)

    spdmTailPointerCertificate48495051 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE48495051", None)
    spdmTailPointerCertificate48495051.setLabel("Tail pointer for Certificate 48,49,50,51")
    spdmTailPointerCertificate48495051.setDescription("Tail pointer for Certificate 48,49,50,51")
    spdmTailPointerCertificate48495051.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate48495051.setVisible(True)

    spdmTailPointerCertificate52535455 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE52535455", None)
    spdmTailPointerCertificate52535455.setLabel("Tail pointer for Certificate 52,53,54,55")
    spdmTailPointerCertificate52535455.setDescription("Tail pointer for Certificate 52,53,54,55")
    spdmTailPointerCertificate52535455.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate52535455.setVisible(True)

    spdmTailPointerCertificate56575859 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE56575859", None)
    spdmTailPointerCertificate56575859.setLabel("Tail pointer for Certificate 56,57,58,59")
    spdmTailPointerCertificate56575859.setDescription("Tail pointer for Certificate 56,57,58,59")
    spdmTailPointerCertificate56575859.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate56575859.setVisible(True)

    spdmTailPointerCertificate60616263 = spdmComponent.createHexSymbol("TAIL_CERTIFICATE60616263", None)
    spdmTailPointerCertificate60616263.setLabel("Tail pointer for Certificate 60,61,62,63")
    spdmTailPointerCertificate60616263.setDescription("Tail pointer for Certificate 60,61,62,63")
    spdmTailPointerCertificate60616263.setDefaultValue(0xFFFFFFFF)
    spdmTailPointerCertificate60616263.setVisible(True)

    isSoteriaComponentConnected = spdmComponent.createBooleanSymbol("SPDM_IS_SG3_COMPONENT_CONNECTED", None)
    isSoteriaComponentConnected.setVisible(False)
    isSoteriaComponentConnected.setDefaultValue(False)
    isSoteriaComponentConnected.setValue(False)

    spdmValueOverrideWarning = spdmComponent.createCommentSymbol("SPDM_VALUE_OVERRIDE_WARNING", None)
    spdmValueOverrideWarning.setVisible(False)
    spdmValueOverrideWarning.setLabel("****These values will be overwritten with values from APCFG table and OTP memory****")
    spdmValueOverrideWarning.setDependencies(spdmValueOverrideWarningDisplay, ["SPDM_IS_SG3_COMPONENT_CONNECTED"])

    activeComponentList = Database.getActiveComponentIDs()
    component = "sg3_src"
    if (component in activeComponentList):
        isSoteriaComponentConnected.setValue(True)
        spdmValueOverrideWarning.setVisible(True)

def spdmValueOverrideWarningDisplay(symbol, event):
    sg3Connected = event["value"]
    symbol.setVisible(sg3Connected == True)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    #Add spdm_config.h
    spdmConfigHeaderFtl = spdmComponent.createFileSymbol(None, None)
    spdmConfigHeaderFtl.setSourcePath("spdm/templates/spdm_config.h.ftl")
    spdmConfigHeaderFtl.setOutputName("spdm_config.h")
    spdmConfigHeaderFtl.setDestPath("spdm/")
    spdmConfigHeaderFtl.setProjectPath("config/" + configName + "/spdm/")
    spdmConfigHeaderFtl.setOverwrite(True)
    spdmConfigHeaderFtl.setType("HEADER")
    spdmConfigHeaderFtl.setMarkup(True) 
    
    #Add spdm.h
    spdmIfaceHeaderFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("spdm/src/spdm.h")
    spdmIfaceHeaderFile.setOutputName("spdm.h")
    spdmIfaceHeaderFile.setDestPath("spdm/")
    spdmIfaceHeaderFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)

    #Add spdm_common.h
    spdmIfaceHeaderFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("spdm/src/spdm_common.h")
    spdmIfaceHeaderFile.setOutputName("spdm_common.h")
    spdmIfaceHeaderFile.setDestPath("spdm/")
    spdmIfaceHeaderFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)

    #Add spdm_common.c
    spdmIfaceHeaderFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("spdm/src/spdm_common.c")
    spdmIfaceHeaderFile.setOutputName("spdm_common.c")
    spdmIfaceHeaderFile.setDestPath("spdm/")
    spdmIfaceHeaderFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("SOURCE")
    spdmIfaceHeaderFile.setMarkup(False)

    #Add core files
    #Add spdm_pkt_prcs.h
    spdmIfaceHeaderFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("spdm/src/spdm_pkt_prcs.h")
    spdmIfaceHeaderFile.setOutputName("spdm_pkt_prcs.h")
    spdmIfaceHeaderFile.setDestPath("spdm/")
    spdmIfaceHeaderFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)
    
    #Add spdm_pkt_prcs.c
    spdmIfaceSourceFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceSourceFile.setSourcePath("spdm/src/spdm_pkt_prcs.c")
    spdmIfaceSourceFile.setOutputName("spdm_pkt_prcs.c")
    spdmIfaceSourceFile.setDestPath("spdm/")
    spdmIfaceSourceFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceSourceFile.setOverwrite(True)
    spdmIfaceSourceFile.setType("SOURCE")
    spdmIfaceSourceFile.setMarkup(False)

    #Add spdm_task.h
    spdmIfaceHeaderFile = spdmComponent.createFileSymbol(None, None)
    spdmIfaceHeaderFile.setSourcePath("spdm/src/spdm_task.h")
    spdmIfaceHeaderFile.setOutputName("spdm_task.h")
    spdmIfaceHeaderFile.setDestPath("spdm/")
    spdmIfaceHeaderFile.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceHeaderFile.setOverwrite(True)
    spdmIfaceHeaderFile.setType("HEADER")
    spdmIfaceHeaderFile.setMarkup(False)
    
    #Add spdm_task.c
    spdmIfaceSourceFileFtl = spdmComponent.createFileSymbol(None, None)
    spdmIfaceSourceFileFtl.setSourcePath("spdm/templates/spdm_task.c.ftl")
    spdmIfaceSourceFileFtl.setOutputName("spdm_task.c")
    spdmIfaceSourceFileFtl.setDestPath("spdm/")
    spdmIfaceSourceFileFtl.setProjectPath("config/" + configName + "/spdm/")
    spdmIfaceSourceFileFtl.setOverwrite(True)
    spdmIfaceSourceFileFtl.setType("SOURCE")
    spdmIfaceSourceFileFtl.setMarkup(True)
