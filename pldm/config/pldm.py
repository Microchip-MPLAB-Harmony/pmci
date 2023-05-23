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

descriptor_bytes = 200

def destroyComponent(pldmCoreComponent):
    Database.sendMessage("MCTP", "PLDM_CONNECTED", {"isConnected":False})
    Database.sendMessage("sg3_src", "PLDM_CONNECTED", {"isConnected":False})
    Database.sendMessage("sg3_lib", "PLDM_CONNECTED", {"isConnected":False})

def handleMessage(messageID, args):
    global isSoteriaComponentConnected

    if(messageID == "SOTERIA_CONNECTED"):
        if(args.get("isConnected") == True):
            isSoteriaComponentConnected.setValue(True)
        else:
            isSoteriaComponentConnected.setValue(False)
    return {}

def pldmValueOverrideWarningDisplay(symbol, event):
    sg3Connected = event["value"]
    symbol.setVisible(sg3Connected == True)

def instantiateComponent(pldmComponent):
    global isSoteriaComponentConnected
    print("PLDM stack component initialize")
    
    autoComponentIDTable = ["MCTP"]
    
    # MCTP is required for PLDM module to function
    pldmComponent.addDependency("MCTP_DEP", "MCTP", None, True, True)
    pldmComponent.setDependencyEnabled("MCTP_DEP", True)
    Database.activateComponents(autoComponentIDTable)
    
    Database.sendMessage("MCTP", "PLDM_CONNECTED", {"isConnected":True})
    Database.sendMessage("sg3_src", "PLDM_CONNECTED", {"isConnected":True})
    Database.sendMessage("sg3_lib", "PLDM_CONNECTED", {"isConnected":True})

    pldmDeviceDesOvr =  pldmComponent.createHexSymbol("PLDM_DEVICE_DESCRIPTOR_OVERRIDE", None)
    pldmDeviceDesOvr.setLabel("PLDM Device Descriptor Override")
    pldmDeviceDesOvr.setDescription("PLDM  Override default values")
    pldmDeviceDesOvr.setMin(0)
    pldmDeviceDesOvr.setDefaultValue(0x01)
    pldmDeviceDesOvr.setMax(0x01)
    pldmDeviceDesOvr.setVisible(False)    

    pldmDeviceCopOvr =  pldmComponent.createHexSymbol("PLDM_OVERRIDE_CAPABLITIES", None)
    pldmDeviceCopOvr.setLabel("PLDM capablities override")
    pldmDeviceCopOvr.setDescription("PLDM  capablities Override default values")
    pldmDeviceCopOvr.setMin(0)
    pldmDeviceCopOvr.setDefaultValue(0x01)
    pldmDeviceCopOvr.setMax(0x01)
    pldmDeviceCopOvr.setVisible(False) 

    pldmDeviceCompClassOvr =  pldmComponent.createHexSymbol("PLDM_OVERRIDE_COMP_CLASSIFICATION", None)
    pldmDeviceCompClassOvr.setLabel("PLDM Override Comp Classification")
    pldmDeviceCompClassOvr.setDescription("PLDM  Override component classification default values")
    pldmDeviceCompClassOvr.setMin(0)
    pldmDeviceCompClassOvr.setDefaultValue(0x01)
    pldmDeviceCompClassOvr.setMax(0x01)
    pldmDeviceCompClassOvr.setVisible(False) 

    pldmDeviceIdentifierLen =  pldmComponent.createHexSymbol("PLDM_DEVICE_IDENTIFIER_LENGTH", None)
    pldmDeviceIdentifierLen.setLabel("PLDM Device Identifier Length")
    pldmDeviceIdentifierLen.setDescription("PLDM  Device Identifier Length")
    pldmDeviceIdentifierLen.setDefaultValue(0xC8)
    pldmDeviceIdentifierLen.setVisible(True)

    pldmDescCount =  pldmComponent.createHexSymbol("PLDM_DESCRIPTOR_COUNT", None)
    pldmDescCount.setLabel("PLDM Descriptor Count")
    pldmDescCount.setDescription("Number of Descriptors")
    pldmDescCount.setMin(0)
    pldmDescCount.setDefaultValue(0x10)
    pldmDescCount.setMax(0xFF)
    pldmDescCount.setVisible(True)

    pldmUDes = []
    index = 0
    for byte_num in range(0, descriptor_bytes, 4):
        pldmUDes.append(pldmComponent.createHexSymbol("PLDM_DESCRIPTOR_"+str((byte_num))+"_"+str(((byte_num+1)))+"_"+str((byte_num+2))+"_"+str((byte_num+3)), None))
        pldmUDes[index].setLabel("PLDM Descriptor bytes["+str((byte_num)) +":"+str(((byte_num+4)-1))+"]")
        pldmUDes[index].setDescription("The actual descriptor Type, Len and Data for each descriptor defined in Descriptor count - Sequence of hex values")
        pldmUDes[index].setDefaultValue(0x00000000)
        pldmUDes[index].setVisible(True)
        index = index +1

    pldmUDes[0].setDefaultValue(0x28537687)
    pldmUDes[1].setDefaultValue(0x54761786)
    pldmUDes[2].setDefaultValue(0x78764662)
    pldmUDes[3].setDefaultValue(0x39990007)
    pldmUDes[4].setDefaultValue(0x51002214)
    pldmUDes[5].setDefaultValue(0x00000025)

    # pldmUDes = pldmComponent.createStringSymbol("PLDM_DESCRIPTOR", None)
    # pldmUDes.setLabel("PLDM Descriptor")
    # pldmUDes.setDescription("The actual descriptor Type, Len and Data for each descriptor defined in Descriptor count - Sequence of hex values")
    # pldmUDes.setDefaultValue("00000255100221439990007787646625476178628537687")
    # pldmUDes.setVisible(True)
    
    pldmUpgradeCap =  pldmComponent.createHexSymbol("PLDM_UPGRADE_CAPABLITIES", None)
    pldmUpgradeCap.setLabel("PLDM Upgrde Capablities ")
    pldmUpgradeCap.setDescription("PLDM Capablities during upgrade")
    pldmUpgradeCap.setMin(0)
    pldmUpgradeCap.setDefaultValue(0x24)
    pldmUpgradeCap.setMax(0xFFFF)
    pldmUpgradeCap.setVisible(True)

    pldmCompClas =  pldmComponent.createHexSymbol("PLDM_COMP_CLASSIFICATION", None)
    pldmCompClas.setLabel("PLDM Component Classification")
    pldmCompClas.setDescription("PLDM  compenent classification")
    pldmCompClas.setMin(0)
    pldmCompClas.setDefaultValue(0x000C)
    pldmCompClas.setMax(0xFFFF)
    pldmCompClas.setVisible(True)

    pldmDeviceTID =  pldmComponent.createHexSymbol("PLDM_DEVICE_TID", None)
    pldmDeviceTID.setLabel("PLDM Device TID")
    pldmDeviceTID.setDescription("PLDM TID for the device")
    pldmDeviceTID.setMin(0)
    pldmDeviceTID.setDefaultValue(0x1)
    pldmDeviceTID.setMax(0xFF)
    pldmDeviceTID.setVisible(True)

    isSoteriaComponentConnected = pldmComponent.createBooleanSymbol("PLDM_IS_SG3_COMPONENT_CONNECTED", None)
    isSoteriaComponentConnected.setVisible(False)
    isSoteriaComponentConnected.setDefaultValue(False)
    isSoteriaComponentConnected.setValue(False)

    pldmValueOverrideWarning = pldmComponent.createCommentSymbol("PLDM_VALUE_OVERRIDE_WARNING", None)
    pldmValueOverrideWarning.setVisible(False)
    pldmValueOverrideWarning.setLabel("****These values will be overwritten with values from APCFG table****")
    pldmValueOverrideWarning.setDependencies(pldmValueOverrideWarningDisplay, ["PLDM_IS_SG3_COMPONENT_CONNECTED"])

    activeComponentList = Database.getActiveComponentIDs()
    component = "sg3_src"
    if (component in activeComponentList):
        isSoteriaComponentConnected.setValue(True)
        pldmValueOverrideWarning.setVisible(True)

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    #Add pldm_config.h
    pldmConfigHeaderFtl = pldmComponent.createFileSymbol(None, None)
    pldmConfigHeaderFtl.setSourcePath("pldm/templates/pldm_config.h.ftl")
    pldmConfigHeaderFtl.setOutputName("pldm_config.h")
    pldmConfigHeaderFtl.setDestPath("pldm/")
    pldmConfigHeaderFtl.setProjectPath("config/" + configName + "/pldm/")
    pldmConfigHeaderFtl.setOverwrite(True)
    pldmConfigHeaderFtl.setType("HEADER")
    pldmConfigHeaderFtl.setMarkup(True) 

    #Add pldm.h
    pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
    pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm.h")
    pldmIfaceHeaderFile.setOutputName("pldm.h")
    pldmIfaceHeaderFile.setDestPath("pldm/")
    pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
    pldmIfaceHeaderFile.setOverwrite(True)
    pldmIfaceHeaderFile.setType("HEADER")
    pldmIfaceHeaderFile.setMarkup(False)

   
    #Add core files
    #Add pldm_pkt_prcs.h
    pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
    pldmIfaceHeaderFile.setSourcePath("pldm/templates/pldm_pkt_prcs.h.ftl")
    pldmIfaceHeaderFile.setOutputName("pldm_pkt_prcs.h")
    pldmIfaceHeaderFile.setDestPath("pldm/")
    pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
    pldmIfaceHeaderFile.setOverwrite(True)
    pldmIfaceHeaderFile.setType("HEADER")
    pldmIfaceHeaderFile.setMarkup(True)
    
    #Add pldm_pkt_prcs.c
    pldmIfaceSourceFile = pldmComponent.createFileSymbol(None, None)
    pldmIfaceSourceFile.setSourcePath("pldm/templates/pldm_pkt_prcs.c.ftl")
    pldmIfaceSourceFile.setOutputName("pldm_pkt_prcs.c")
    pldmIfaceSourceFile.setDestPath("pldm/")
    pldmIfaceSourceFile.setProjectPath("config/" + configName + "/pldm/")
    pldmIfaceSourceFile.setOverwrite(True)
    pldmIfaceSourceFile.setType("SOURCE")
    pldmIfaceSourceFile.setMarkup(True)

    if(isSoteriaComponentConnected.getValue() == False):
        #Add pldm_task.h
        pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
        pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm_task.h")
        pldmIfaceHeaderFile.setOutputName("pldm_task.h")
        pldmIfaceHeaderFile.setDestPath("pldm/")
        pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceHeaderFile.setOverwrite(True)
        pldmIfaceHeaderFile.setType("HEADER")
        pldmIfaceHeaderFile.setMarkup(False)
        
        #Add pldm_task.c
        pldmIfaceSourceFileFtl = pldmComponent.createFileSymbol(None, None)
        pldmIfaceSourceFileFtl.setSourcePath("pldm/templates/pldm_task.c.ftl")
        pldmIfaceSourceFileFtl.setOutputName("pldm_task.c")
        pldmIfaceSourceFileFtl.setDestPath("pldm/")
        pldmIfaceSourceFileFtl.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceSourceFileFtl.setOverwrite(True)
        pldmIfaceSourceFileFtl.setType("SOURCE")
        pldmIfaceSourceFileFtl.setMarkup(True)

    if(isSoteriaComponentConnected.getValue() == False):
        #Add pldm_common.h
        pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
        pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm_common_app.h")
        pldmIfaceHeaderFile.setOutputName("pldm_common.h")
        pldmIfaceHeaderFile.setDestPath("pldm/")
        pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceHeaderFile.setOverwrite(True)
        pldmIfaceHeaderFile.setType("HEADER")
        pldmIfaceHeaderFile.setMarkup(False)

        #Add pldm_common.c
        pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
        pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm_common_app.c")
        pldmIfaceHeaderFile.setOutputName("pldm_common.c")
        pldmIfaceHeaderFile.setDestPath("pldm/")
        pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceHeaderFile.setOverwrite(True)
        pldmIfaceHeaderFile.setType("SOURCE")
        pldmIfaceHeaderFile.setMarkup(False)        
    else:
        #Add pldm_common.h
        pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
        pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm_common_sg_app.h")
        pldmIfaceHeaderFile.setOutputName("pldm_common.h")
        pldmIfaceHeaderFile.setDestPath("pldm/")
        pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceHeaderFile.setOverwrite(True)
        pldmIfaceHeaderFile.setType("HEADER")
        pldmIfaceHeaderFile.setMarkup(False)

        #Add pldm_common.c
        pldmIfaceHeaderFile = pldmComponent.createFileSymbol(None, None)
        pldmIfaceHeaderFile.setSourcePath("pldm/src/pldm_common_sg_app.c")
        pldmIfaceHeaderFile.setOutputName("pldm_common.c")
        pldmIfaceHeaderFile.setDestPath("pldm/")
        pldmIfaceHeaderFile.setProjectPath("config/" + configName + "/pldm/")
        pldmIfaceHeaderFile.setOverwrite(True)
        pldmIfaceHeaderFile.setType("SOURCE")
        pldmIfaceHeaderFile.setMarkup(False)        