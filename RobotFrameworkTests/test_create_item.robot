*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}               http://localhost:3000
${BROWSER}           Chrome

${NAME_INPUT}        id:name                # Locator for the name input field
${DESCRIPTION_INPUT}    id:description         # Locator for the description input field
${ADD_BUTTON}        xpath://button[text()='Add Item']    # Locator for the "Add Item" button
${ITEM_LIST}         id:item-list           # Locator for the item list

${EXPECTED_NAME}     123
${EXPECTED_DESC}     456

*** Test Cases ***
Test Creating an Item with 123 and 456
    [Documentation]    This test creates a new item with name '123' and description '456' and verifies that it appears in the item list.
    
    Open Browser To Application
    Input Item Details
    Submit Form
    Verify Item In List
    Close Browser

*** Keywords ***
Open Browser To Application
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

Input Item Details
    Input Text    ${NAME_INPUT}         ${EXPECTED_NAME}
    Input Text    ${DESCRIPTION_INPUT}  ${EXPECTED_DESC}

Submit Form
    Click Button    ${ADD_BUTTON}

Verify Item In List
    Wait Until Element Contains    ${ITEM_LIST}    ${EXPECTED_NAME}    5s
    Wait Until Element Contains    ${ITEM_LIST}    ${EXPECTED_DESC}    5s
