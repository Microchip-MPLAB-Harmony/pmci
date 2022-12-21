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
phyLayerList = ["Select", "I2C"]
i2cSpeedList = ["100", "400", "1000"]

def handleMessage(messageID, args):
    global isSpdmComponentConnected
    global isPldmComponentConnected
    global isSpdmRequired
    global isPldmRequired
    global isSoteriaComponentConnected
    
    if(messageID == "SPDM_CONNECTED"):
        if(args.get("isConnected") == True):
            isSpdmComponentConnected.setValue(True)
            isSpdmRequired.setValue(True)
            isSpdmRequired.setReadOnly(True)
        else:
            isSpdmComponentConnected.setValue(False)
            isSpdmRequired.setValue(False)
            isSpdmRequired.setReadOnly(False)
    if(messageID == "PLDM_CONNECTED"):
        if(args.get("isConnected") == True):
            isPldmComponentConnected.setValue(True)
            isPldmRequired.setValue(True)
            isPldmRequired.setReadOnly(True)
        else:
            isPldmComponentConnected.setValue(False)
            isPldmRequired.setValue(False)
            isPldmRequired.setReadOnly(False)
    if(messageID == "SOTERIA_CONNECTED"):
        if(args.get("isConnected") == True):
            isSoteriaComponentConnected.setValue(True)
        else:
            isSoteriaComponentConnected.setValue(False)

def mctpI2CPortUpdate(symbol, event):
    selectedPhy = event["value"]
    symbol.setVisible(selectedPhy == "I2C")

def mctpIsSpdmRequired(symbol, event):
    usrSelection = event["value"]
    symbol.setValue(usrSelection == True)

def mctpIsPldmRequired(symbol, event):
    usrSelection = event["value"]
    symbol.setValue(usrSelection == True)

def mctpValueOverrideWarningDisplay(symbol, event):
    sg3Connected = event["value"]
    symbol.setVisible(sg3Connected == True)

def onAttachmentConnected(source, target):
    global isRtosComponentConnected
    if(target["component"].getID() == "FreeRTOS"):
        print("RTOS connected")
        isRtosComponentConnected.setValue(True)

def onAttachmentDisconnected(source, target):
    global isRtosComponentConnected
    if(target["component"].getID() == "FreeRTOS"):
        print("RTOS disconnected")
        isRtosComponentConnected.setValue(False)

def instantiateComponent(mctpComponent):

    global phyLayerSelection
    global isSpdmComponentConnected
    global isPldmComponentConnected
    global isRtosComponentConnected
    global isSpdmRequired
    global isPldmRequired
    global isSoteriaComponentConnected

    print("MCTP stack component initialize")
    
    autoComponentIDTable = ["FreeRTOS", "HarmonyCore"]

    # FreeRTOS is required for MCTP module to function
    mctpComponent.addDependency("FreeRTOS_DEP", "RTOS", None, True, True)
    mctpComponent.setDependencyEnabled("FreeRTOS_DEP", True)

    Database.activateComponents(autoComponentIDTable)
    
    # EC slave address
    mctpSourceEid = mctpComponent.createHexSymbol("MCTP_EC_SLAVE_ADDR", None)
    mctpSourceEid.setHelp("mcc_h3_manager_configurations")
    mctpSourceEid.setLabel("EC slave address")
    mctpSourceEid.setDescription("Value of EC physical layer address")
    mctpSourceEid.setReadOnly(False)
    mctpSourceEid.setDefaultValue(0x64)
    mctpSourceEid.setVisible(True)
    
    # MCTP Source EID
    mctpSourceEid = mctpComponent.createHexSymbol("MCTP_EC_EID", None)
    mctpSourceEid.setHelp("mcc_h3_manager_configurations")
    mctpSourceEid.setLabel("Device Endpoint ID")
    mctpSourceEid.setDescription("Value of Source Endpoint ID field")
    mctpSourceEid.setReadOnly(False)
    mctpSourceEid.setDefaultValue(0x94)
    mctpSourceEid.setVisible(True)
    
    # MCTP Destination EID
    mctpDestinationEid = mctpComponent.createHexSymbol("MCTP_HOST_EID", None)
    mctpDestinationEid.setHelp("mcc_h3_manager_configurations")
    mctpDestinationEid.setLabel("Host Endpoint ID")
    mctpDestinationEid.setDescription("Value of Destination Endpoint ID field")
    mctpDestinationEid.setReadOnly(False)
    mctpDestinationEid.setDefaultValue(0x95)
    mctpDestinationEid.setVisible(True)
    
    # MCTP task priority selection
    mctpTaskPriority = mctpComponent.createIntegerSymbol("MCTP_TASK_PRIORITY", None)
    mctpTaskPriority.setHelp("mcc_h3_manager_configurations")
    mctpTaskPriority.setLabel("MCTP task priority")
    mctpTaskPriority.setDescription("Value of MCTP task priority")
    mctpTaskPriority.setReadOnly(False)
    mctpTaskPriority.setMin(1)
    mctpTaskPriority.setMax(999999999)
    mctpTaskPriority.setDefaultValue(2)
    mctpTaskPriority.setVisible(True)

    mctpTaskPrioritySelectionGuide = mctpComponent.createCommentSymbol("MCTP_TASK_PRIORITY_SELECTION_GUIDE", None)
    mctpTaskPrioritySelectionGuide.setLabel("**** Task priority should be less than PHY driver priority and greater than idle task priority ****")
    
    # Physical layer selection
    phyLayerSelection = mctpComponent.createComboSymbol("MCTP_PHY_LAYER", None, phyLayerList) 
    phyLayerSelection.setHelp("mcc_h3_manager_configurations")
    phyLayerSelection.setLabel("Physical layer")
    phyLayerSelection.setVisible(True)
    phyLayerSelection.setDescription("MCTP Physical layer selection")
    phyLayerSelection.setDefaultValue("Select")
    
    # MCTP I2C controller selection
    mctpI2CCoontrollerSelect = mctpComponent.createIntegerSymbol("MCTP_I2C_CONTROLLER", None)
    mctpI2CCoontrollerSelect.setHelp("mcc_h3_manager_configurations")
    mctpI2CCoontrollerSelect.setLabel("MCTP I2C controller")
    mctpI2CCoontrollerSelect.setVisible(False)
    mctpI2CCoontrollerSelect.setDescription("I2C controller to use")
    mctpI2CCoontrollerSelect.setMin(0)
    mctpI2CCoontrollerSelect.setMax(4)
    mctpI2CCoontrollerSelect.setDefaultValue(0)
    mctpI2CCoontrollerSelect.setDependencies(mctpI2CPortUpdate, ["MCTP_PHY_LAYER"])
    
    # MCTP I2C port selection
    mctpI2CportSelect = mctpComponent.createIntegerSymbol("MCTP_I2C_PORT", None)
    mctpI2CportSelect.setHelp("mcc_h3_manager_configurations")
    mctpI2CportSelect.setLabel("MCTP I2C port")
    mctpI2CportSelect.setVisible(False)
    mctpI2CportSelect.setDescription("I2C controller port to use")
    mctpI2CportSelect.setMin(0)
    mctpI2CportSelect.setMax(15)
    mctpI2CportSelect.setDefaultValue(0)
    mctpI2CportSelect.setDependencies(mctpI2CPortUpdate, ["MCTP_PHY_LAYER"])
    
    # MCTP I2C speed selection
    mctpI2CClkFreqSelect = mctpComponent.createComboSymbol("MCTP_I2C_CLK_FREQ", None, i2cSpeedList) 
    mctpI2CClkFreqSelect.setHelp("mcc_h3_manager_configurations")
    mctpI2CClkFreqSelect.setLabel("I2C Clock Frequency in kHz")
    mctpI2CClkFreqSelect.setVisible(False)
    mctpI2CClkFreqSelect.setDescription("MCTP I2C clock frequency selection")
    mctpI2CClkFreqSelect.setDefaultValue("100")
    mctpI2CClkFreqSelect.setDependencies(mctpI2CPortUpdate, ["MCTP_PHY_LAYER"])
    
    isControlPktRequired = mctpComponent.createBooleanSymbol("MCTP_IS_CONTROL_REQUIRED", None)
    isControlPktRequired.setLabel("MCTP control packet processing")
    isControlPktRequired.setVisible(True)
    isControlPktRequired.setDefaultValue(True)
    isControlPktRequired.setReadOnly(True)

    isSpdmRequired = mctpComponent.createBooleanSymbol("MCTP_IS_SPDM_REQUIRED", None)
    isSpdmRequired.setLabel("SPDM packet routing")
    isSpdmRequired.setVisible(True)
    isSpdmRequired.setDefaultValue(False)
    isSpdmRequired.setValue(False)

    isPldmRequired = mctpComponent.createBooleanSymbol("MCTP_IS_PLDM_REQUIRED", None)
    isPldmRequired.setLabel("PLDM packet routing")
    isPldmRequired.setVisible(False)
    isPldmRequired.setDefaultValue(False)
    isPldmRequired.setValue(False)

    isSpdmComponentConnected = mctpComponent.createBooleanSymbol("MCTP_IS_SPDM_COMPONENT_CONNECTED", None)
    isSpdmComponentConnected.setVisible(False)
    isSpdmComponentConnected.setDefaultValue(False)
    isSpdmComponentConnected.setValue(False)
    isSpdmComponentConnected.setDependencies(mctpIsSpdmRequired, ["MCTP_IS_SPDM_REQUIRED"])
    
    isPldmComponentConnected = mctpComponent.createBooleanSymbol("MCTP_IS_PLDM_COMPONENT_CONNECTED", None)
    isPldmComponentConnected.setVisible(False)
    isPldmComponentConnected.setDefaultValue(False)
    isPldmComponentConnected.setValue(False)
    isPldmComponentConnected.setDependencies(mctpIsPldmRequired, ["MCTP_IS_PLDM_REQUIRED"])
    
    isRtosComponentConnected = mctpComponent.createBooleanSymbol("MCTP_IS_RTOS_COMPONENT_CONNECTED", None)
    isRtosComponentConnected.setVisible(False)
    isRtosComponentConnected.setDefaultValue(False)
    isRtosComponentConnected.setValue(False)

    isSoteriaComponentConnected = mctpComponent.createBooleanSymbol("MCTP_IS_SG3_COMPONENT_CONNECTED", None)
    isSoteriaComponentConnected.setVisible(False)
    isSoteriaComponentConnected.setDefaultValue(False)
    isSoteriaComponentConnected.setValue(False)

    mctpValueOverrideWarning = mctpComponent.createCommentSymbol("MCTP_VALUE_OVERRIDE_WARNING", None)
    mctpValueOverrideWarning.setVisible(False)
    mctpValueOverrideWarning.setLabel("****These values will be overwritten with values from APCFG table and OTP memory****")
    mctpValueOverrideWarning.setDependencies(mctpValueOverrideWarningDisplay, ["MCTP_IS_SG3_COMPONENT_CONNECTED"])

    
    ############################################################################
    #### Code Generation ####
    ############################################################################
    configName = Variables.get("__CONFIGURATION_NAME")
    #Add configuration files to project
    #Add mctp_config.h
    mctpConfigHeaderFtl = mctpComponent.createFileSymbol(None, None)
    mctpConfigHeaderFtl.setSourcePath("mctp/templates/mctp_config.h.ftl")
    mctpConfigHeaderFtl.setOutputName("mctp_config.h")
    mctpConfigHeaderFtl.setDestPath("mctp/")
    mctpConfigHeaderFtl.setProjectPath("config/" + configName + "/mctp/")
    mctpConfigHeaderFtl.setOverwrite(True)
    mctpConfigHeaderFtl.setType("HEADER")
    mctpConfigHeaderFtl.setMarkup(True)
    
    #Add interface file to project
    #Add mctp.h
    mctpSmbusIfaceHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpSmbusIfaceHeaderFile.setSourcePath("mctp/templates/mctp.h.ftl")
    mctpSmbusIfaceHeaderFile.setOutputName("mctp.h")
    mctpSmbusIfaceHeaderFile.setDestPath("mctp/")
    mctpSmbusIfaceHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpSmbusIfaceHeaderFile.setOverwrite(True)
    mctpSmbusIfaceHeaderFile.setType("HEADER")
    mctpSmbusIfaceHeaderFile.setMarkup(True)
    
    #Add core files
    #Add mctp_common.h
    mctpCommonHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpCommonHeaderFile.setSourcePath("mctp/src/mctp_common.h")
    mctpCommonHeaderFile.setOutputName("mctp_common.h")
    mctpCommonHeaderFile.setDestPath("mctp/")
    mctpCommonHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpCommonHeaderFile.setOverwrite(True)
    mctpCommonHeaderFile.setType("HEADER")
    mctpCommonHeaderFile.setMarkup(False)
    #Add mctp_base.h
    mctpBaseHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpBaseHeaderFile.setSourcePath("mctp/templates/mctp_base.h.ftl")
    mctpBaseHeaderFile.setOutputName("mctp_base.h")
    mctpBaseHeaderFile.setDestPath("mctp/")
    mctpBaseHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpBaseHeaderFile.setOverwrite(True)
    mctpBaseHeaderFile.setType("HEADER")
    mctpBaseHeaderFile.setMarkup(True)
    #Add mctp_base.c
    mctpBaseSourceFile = mctpComponent.createFileSymbol(None, None)
    mctpBaseSourceFile.setSourcePath("mctp/templates/mctp_base.c.ftl")
    mctpBaseSourceFile.setOutputName("mctp_base.c")
    mctpBaseSourceFile.setDestPath("mctp/")
    mctpBaseSourceFile.setProjectPath("config/" + configName + "/mctp/")
    mctpBaseSourceFile.setOverwrite(True)
    mctpBaseSourceFile.setType("SOURCE")
    mctpBaseSourceFile.setMarkup(True)
    #Add mctp_control.h
    mctpControlHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpControlHeaderFile.setSourcePath("mctp/src/mctp_control.h")
    mctpControlHeaderFile.setOutputName("mctp_control.h")
    mctpControlHeaderFile.setDestPath("mctp/")
    mctpControlHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpControlHeaderFile.setOverwrite(True)
    mctpControlHeaderFile.setType("HEADER")
    mctpControlHeaderFile.setMarkup(False)
    #Add mctp_control.c
    mctpControlSourceFile = mctpComponent.createFileSymbol(None, None)
    mctpControlSourceFile.setSourcePath("mctp/templates/mctp_control.c.ftl")
    mctpControlSourceFile.setOutputName("mctp_control.c")
    mctpControlSourceFile.setDestPath("mctp/")
    mctpControlSourceFile.setProjectPath("config/" + configName + "/mctp/")
    mctpControlSourceFile.setOverwrite(True)
    mctpControlSourceFile.setType("SOURCE")
    mctpControlSourceFile.setMarkup(True)
    #Add mctp_smbus.h
    mctpSmbusHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpSmbusHeaderFile.setSourcePath("mctp/templates/mctp_smbus.h.ftl")
    mctpSmbusHeaderFile.setOutputName("mctp_smbus.h")
    mctpSmbusHeaderFile.setDestPath("mctp/")
    mctpSmbusHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpSmbusHeaderFile.setOverwrite(True)
    mctpSmbusHeaderFile.setType("HEADER")
    mctpSmbusHeaderFile.setMarkup(True)
    #Add mctp_smbus.c
    mctpSmbusSourceFile = mctpComponent.createFileSymbol(None, None)
    mctpSmbusSourceFile.setSourcePath("mctp/templates/mctp_smbus.c.ftl")
    mctpSmbusSourceFile.setOutputName("mctp_smbus.c")
    mctpSmbusSourceFile.setDestPath("mctp/")
    mctpSmbusSourceFile.setProjectPath("config/" + configName + "/mctp/")
    mctpSmbusSourceFile.setOverwrite(True)
    mctpSmbusSourceFile.setType("SOURCE")
    mctpSmbusSourceFile.setMarkup(True)
    #Add mctp_task.h
    mctpSmbusHeaderFile = mctpComponent.createFileSymbol(None, None)
    mctpSmbusHeaderFile.setSourcePath("mctp/templates/mctp_task.h.ftl")
    mctpSmbusHeaderFile.setOutputName("mctp_task.h")
    mctpSmbusHeaderFile.setDestPath("mctp/")
    mctpSmbusHeaderFile.setProjectPath("config/" + configName + "/mctp/")
    mctpSmbusHeaderFile.setOverwrite(True)
    mctpSmbusHeaderFile.setType("HEADER")
    mctpSmbusHeaderFile.setMarkup(True)
    #Add mctp_task.c
    mctpSmbusSourceFile = mctpComponent.createFileSymbol(None, None)
    mctpSmbusSourceFile.setSourcePath("mctp/templates/mctp_task.c.ftl")
    mctpSmbusSourceFile.setOutputName("mctp_task.c")
    mctpSmbusSourceFile.setDestPath("mctp/")
    mctpSmbusSourceFile.setProjectPath("config/" + configName + "/mctp/")
    mctpSmbusSourceFile.setOverwrite(True)
    mctpSmbusSourceFile.setType("SOURCE")
    mctpSmbusSourceFile.setMarkup(True)
    
    #Project configurations
    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32C_INCLUDE_DIR_MCTP", None)
    xc32ProjSettings.setCategory("C32")
    xc32ProjSettings.setAppend(True, ";")
    xc32ProjSettings.setKey("extra-include-directories")
    xc32ProjSettings.setValue("../src/config/" + configName + "/mctp/")
    
    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32CPP_INCLUDE_DIR_MCTP", None)
    xc32ProjSettings.setCategory("C32CPP")
    xc32ProjSettings.setAppend(True, ";")
    xc32ProjSettings.setKey("extra-include-directories")
    xc32ProjSettings.setValue("../src/config/" + configName + "/mctp/")
    
    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32C_ADDITIONAL_WARNINGS", None)
    xc32ProjSettings.setCategory("C32")
    xc32ProjSettings.setKey("additional-warnings")
    xc32ProjSettings.setValue("false")

    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32C_WERROR", None)
    xc32ProjSettings.setCategory("C32")
    xc32ProjSettings.setKey("make-warnings-into-errors")
    xc32ProjSettings.setValue("false")

    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32CPP_ADDITIONAL_WARNINGS", None)
    xc32ProjSettings.setCategory("C32CPP")
    xc32ProjSettings.setKey("additional-warnings")
    xc32ProjSettings.setValue("false")

    xc32ProjSettings = mctpComponent.createSettingSymbol("XC32CPP_WERROR", None)
    xc32ProjSettings.setCategory("C32CPP")
    xc32ProjSettings.setKey("make-warnings-into-errors")
    xc32ProjSettings.setValue("false")

    xc32Includes = mctpComponent.createListEntrySymbol("STANDARD_INCLUDES_STRING_H", None)
    xc32Includes.setVisible(False)
    xc32Includes.addValue("#include <string.h>")
    xc32Includes.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")