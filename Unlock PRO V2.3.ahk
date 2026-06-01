; ============================================
; RemoverX86 - Painel de Controle (Integrado com Shift)
; REMOVER X86 - 0 BUGS
; ============================================

#SingleInstance Force
#NoEnv
SendMode Input

global pressing := false
global scriptAtivo := false
global wasPressing := false
global isJumping := false

; ========== VARIÁVEIS DO SISTEMA SHIFT ==========
global shiftModeEnabled := true      ; Modo shift ativado (ponto desliga/liga)
global shiftActive := false           ; Estado do shift (P pressionado ou não)
global lastMouseState := 0

; ========== CONFIGURACAO DO HWID ==========
EMBEDDED_HWID := ""
; ==========================================

; ========== VERIFICACAO DE HWID ==========
if (EMBEDDED_HWID == "") {
    MsgBox, 16, Erro de Compilacao, Este executavel nao tem HWID configurado!
    ExitApp
}

GetHWID() {
    hwid := ""
    
    DriveGet, volSerial, Serial, C:
    hwid .= volSerial
    
    ComputerName := A_ComputerName
    hwid .= ComputerName
    
    try {
        for obj in ComObjGet("winmgmts:").ExecQuery("SELECT SerialNumber FROM Win32_BaseBoard") {
            hwid .= obj.SerialNumber
        }
    }
    
    try {
        for obj in ComObjGet("winmgmts:").ExecQuery("SELECT ProcessorId FROM Win32_Processor") {
            hwid .= obj.ProcessorId
        }
    }
    
    try {
        for obj in ComObjGet("winmgmts:").ExecQuery("SELECT MACAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True") {
            hwid .= obj.MACAddress
            break
        }
    }
    
    RegRead, productId, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductId
    hwid .= productId
    
    hash := 5381
    Loop, Parse, hwid
    {
        char := Asc(A_LoopField)
        hash := ((hash << 5) + hash) + char
    }
    SetFormat, IntegerFast, Hex
    hashHex := hash + 0
    SetFormat, IntegerFast, D
    return hashHex
}

currentHWID := GetHWID()

if (currentHWID != EMBEDDED_HWID) {
    MsgBox, 16, Erro de Ativacao, Este programa nao esta autorizado para este computador!
    ExitApp
}

; ========== INTERFACE PRINCIPAL ==========
MainGui:
Gui, New, +AlwaysOnTop +hwndhGui
Gui, Color, 1E1E2F
Gui, Font, s12 cWhite bold, Segoe UI

Gui, Add, Text, x20 y20 w280 center, REMOVER X86 - TELA PARADA
Gui, Font, s9 cGray
Gui, Add, Text, x20 y50 w280 center, DEV - esieme

Gui, Font, s10 cWhite bold
Gui, Add, Text, x20 y90 w120, Status:
Gui, Font, s10 cRed bold
Gui, Add, Text, x140 y90 w160 vStatusText, DESATIVADO

Gui, Font, s10 cWhite bold
Gui, Add, Button, x20 y130 w120 gAtivarScript, ATIVAR SCRIPT
Gui, Add, Button, x160 y130 w120 gDesativarScript, DESATIVAR SCRIPT

; Indicador do modo shift
Gui, Font, s9 cWhite bold
Gui, Add, Text, x20 y165 w100, Modo Shift:
Gui, Font, s9 cLime bold
Gui, Add, Text, x130 y165 w150 vShiftStatus, ATIVADO (.)

Gui, Font, s8 cGray
Gui, Add, Text, x20 y185 w280 0x10

Gui, Add, Text, x20 y205 w280 center, CONFIGURACAO NO JOGO:
Gui, Font, s9 cYellow
Gui, Add, Text, x20 y230 w280 center, Correr = P
Gui, Add, Text, x20 y250 w280 center, Andar Frente = W

Gui, Font, s9 cCyan
Gui, Add, Text, x20 y280 w280 center, FUNCOES DO SCRIPT:
Gui, Font, s8 cWhite
Gui, Add, Text, x20 y300 w130, Shift:
Gui, Add, Text, x150 y300 w150, Alterna Corrida
Gui, Add, Text, x20 y320 w130, WASD / Alt / C:
Gui, Add, Text, x150 y320 w150, Para a Corrida
Gui, Add, Text, x20 y340 w130, Botao Direito:
Gui, Add, Text, x150 y340 w150, Para a Corrida
Gui, Add, Text, x20 y360 w130, Botao Esquerdo:
Gui, Add, Text, x150 y360 w150, Para a Corrida (solo)
Gui, Add, Text, x20 y380 w130, Tab:
Gui, Add, Text, x150 y380 w150, Mochila c/ correcao
Gui, Add, Text, x20 y400 w130, Espaco:
Gui, Add, Text, x150 y400 w150, Pulo c/ correcao
Gui, Add, Text, x20 y420 w130, Ponto (.):
Gui, Add, Text, x150 y420 w150, Ativa/Desativa Modo Shift

Gui, Add, Text, x20 y445 w280 0x10

Gui, Font, s9 cBlue underline
Gui, Add, Button, x20 y455 w85 gLinkDiscord, DISCORD
Gui, Add, Button, x115 y455 w85 gLinkTikTok, TIKTOK
Gui, Add, Button, x210 y455 w85 gLinkLoja, LOJA

Gui, Font, s8 cGray
Gui, Add, Text, x20 y490 w280 center, - © 2026 By esieme - Todos os direitos reservados

Gui, Show, w320 h530, RemoverX86 - TELA PARADA

; Inicia o timer do modo shift
SetTimer, CheckShiftKeys, 10
return

; ========== FUNCOES DO PAINEL ==========
AtivarScript:
    scriptAtivo := true
    GuiControl, , StatusText, ATIVADO
    GuiControl, +cGreen, StatusText
    SoundBeep, 1000, 200
return

DesativarScript:
    scriptAtivo := false
    
    ; Desativa ambos os sistemas de corrida
    if (pressing) {
        pressing := false
        Send, {p up}{w up}
    }
    if (shiftActive) {
        shiftActive := false
        Send, {p up}
    }
    
    GuiControl, , StatusText, DESATIVADO
    GuiControl, +cRed, StatusText
    SoundBeep, 800, 200
return

LinkDiscord:
    Run, https://discord.gg/Cz2fWZrVfz
return

LinkTikTok:
    Run, https://www.tiktok.com/@hunterxomaislimpo
return

LinkLoja:
    Run, https://priv8h4x.centralcart.com.br
return

GuiClose:
    if (pressing) {
        Send, {p up}{w up}
    }
    if (shiftActive) {
        Send, {p up}
    }
    ExitApp
return

; ========== INICIALIZACAO ==========
#Persistent
Gosub, MainGui
return

; ========== SISTEMA SHIFT (MODO AUTOMÁTICO) ==========
; Tecla ponto (.) - Ativa/Desativa o modo shift
.::
    if (!scriptAtivo)
        return
    
    shiftModeEnabled := !shiftModeEnabled
    
    if (shiftModeEnabled) {
        GuiControl, , ShiftStatus, ATIVADO (.)
        GuiControl, +cLime, ShiftStatus
        ToolTip, Modo Shift ATIVADO, 100, 100
    } else {
        ; Desativa o shift se estiver ativo
        if (shiftActive) {
            shiftActive := false
            Send, {p up}
        }
        GuiControl, , ShiftStatus, DESATIVADO
        GuiControl, +cRed, ShiftStatus
        ToolTip, Modo Shift DESATIVADO, 100, 100
    }
    
    SetTimer, RemoveToolTip, -1500
return

RemoveToolTip:
    ToolTip
return

; Timer que verifica as teclas para o modo shift
CheckShiftKeys:
    if (!scriptAtivo || !shiftModeEnabled) {
        return
    }
    
    ; Verifica teclas WASD
    aDown := GetKeyState("a", "P")
    wDown := GetKeyState("w", "P")
    sDown := GetKeyState("s", "P")
    dDown := GetKeyState("d", "P")
    
    ; Verifica clique do mouse (prioridade máxima para parar)
    mouseDown := GetKeyState("LButton", "P")
    
    ; Se clicou com o mouse, para imediatamente
    if (mouseDown) {
        if (shiftActive) {
            shiftActive := false
            Send, {p up}
        }
        return
    }
    
    ; Se alguma tecla WASD estiver pressionada, ativa o shift
    if (aDown || wDown || sDown || dDown) {
        if (!shiftActive) {
            Send, {p down}
            shiftActive := true
        }
    } else {
        ; Se nenhuma tecla WASD está pressionada, desativa o shift
        if (shiftActive) {
            Send, {p up}
            shiftActive := false
        }
    }
return

; ========== SCRIPT DE CORRIDA ORIGINAL (Shift manual) ==========

; Shift alterna: segura P + W
LShift::
RShift::
    if (!scriptAtivo)
        return
    
    ; Se o modo shift automático estiver ativo, este shift manual não interfere
    ; Apenas executa a função original
    
    if (!pressing) {
        Send, {LAlt up}{RAlt up}
        Sleep, 1
        pressing := true
        Send, {p down}{w down}
    } else {
        pressing := false
        Send, {p up}{w up}
    }
return

; Alt: agacha (nao interfere na corrida)
~LAlt::
~RAlt::
    if (!scriptAtivo)
        return
return

; WASD, C e botao direito param a corrida (sistema original)
~w::
~a::
~s::
~d::
~c::
~RButton::
    if (!scriptAtivo)
        return
    if (pressing) {
        pressing := false
        Send, {p up}{w up}
    }
return

; Botao esquerdo do mouse (atirar) - Só para a corrida se NAO estiver pulando (sistema original)
~LButton::
    if (!scriptAtivo)
        return
    if (pressing && !isJumping) {
        pressing := false
        Send, {p up}{w up}
    }
return

; Tab: solta e reativa (sistema original)
~Tab::
    if (!scriptAtivo)
        return
    if (pressing) {
        Send, {p up}{w up}
        Sleep, 30
        Send, {p down}{w down}
    }
return

; Pulo: guarda estado, solta tudo, depois restaura (sistema original)
~Space::
    if (!scriptAtivo)
        return
    
    isJumping := true
    wasPressing := pressing
    
    if (pressing) {
        pressing := false
        Send, {p up}{w up}
    }
    
    Sleep, 640
    
    if (wasPressing) {
        pressing := true
        Send, {p down}{w down}
    }
    
    isJumping := false
return

; Ctrl+Alt+X - Recarrega o script (atalho extra)
^!x::
    if (pressing) {
        Send, {p up}{w up}
    }
    if (shiftActive) {
        Send, {p up}
    }
    Reload
return