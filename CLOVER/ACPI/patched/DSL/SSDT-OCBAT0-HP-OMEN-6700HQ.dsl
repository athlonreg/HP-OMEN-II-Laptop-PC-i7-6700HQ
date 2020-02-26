//// battery
// In config ACPI, UPBI to XPBI
// Find:     5550424900
// Replace:  5850424900
//
// In config ACPI, UPBS to XPBS
// Find:     5550425300
// Replace:  5850425300
//
// In config ACPI, SMRD to XMRD
// Find:     534d524404
// Replace:  584d524404
//
// In config ACPI, CLRI to XLRI
// Find:     434C524908
// Replace:  584C524908
//
DefinitionBlock ("", "SSDT", 2, "ACDT", "BAT0", 0x00000000)
{
    External (_SB.BAT0, DeviceObj)
    External (_SB.PBFE, MethodObj)
    External (_SB.GBFE, MethodObj)
    External (_SB.PCI0.ACEL, DeviceObj)
    External (_SB.PCI0.LPCB.EC0, DeviceObj)
    //
    External (_SB.BAT0.FABL, IntObj)
    External (_SB.BAT0.PBIF, PkgObj)
    External (_SB.BAT0.PBST, PkgObj)
    External (_SB.BAT0._STA, MethodObj)
    External (_SB.BAT0.UPUM, MethodObj)
    //
    External (_SB.BAT0.XPBI, MethodObj)
    External (_SB.BAT0.XPBS, MethodObj)
    External (_SB.PCI0.ACEL.XLRI, MethodObj)
    External (_SB.PCI0.LPCB.EC0.XMRD, MethodObj)
    //
    External (_SB.PCI0.LPCB.EC0.ECOK, IntObj)
    //
    External (_SB.PCI0.LPCB.EC0.MUT0, MutexObj)
    //
    External (_SB.PCI0.LPCB.EC0.SW2S, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMCM, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMAD, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMPR, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.SMB0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BCNT, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.MBNH, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVLB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BVHB, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.MBST, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC0.BACR, FieldUnitObj)

    Method (B1B2, 2, NotSerialized)
    {
        Return ((Arg0 | (Arg1 << 0x08)))
    }

    Scope (_SB.PCI0.LPCB.EC0)
    {
        Method (RE1B, 1, NotSerialized)
        {
            OperationRegion(ERAM, EmbeddedControl, Arg0, 1)
            Field(ERAM, ByteAcc, NoLock, Preserve) { BYTE, 8 }
            Return(BYTE)
        }
        
        Method (RECB, 2, Serialized)
        {
            ShiftRight(Arg1, 3, Arg1)
            Name(TEMP, Buffer(Arg1) { })
            Add(Arg0, Arg1, Arg1)
            Store(0, Local0)
            While (LLess(Arg0, Arg1))
            {
                Store(RE1B(Arg0), Index(TEMP, Local0))
                Increment(Arg0)
                Increment(Local0)
            }
            Return(TEMP)
        }
        
        OperationRegion (ERM2, EmbeddedControl, Zero, 0xFF)
        Field (ERM2, ByteAcc, NoLock, Preserve)
        {
            Offset (0x70), 
            ,   8, 
            ,   8, 
            FCC0,   8, 
            FCC1,   8,
            Offset (0x82), 
            ,   8, 
            CUR0,   8, 
            CUR1,   8, 
            BRM0,   8, 
            BRM1,   8, 
            BCV0,   8, 
            BCV1,   8, 
        }
        
        Field (ERM2, ByteAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            MW00,   8, 
            MW01,   8
        }
    }
    
    Scope (_SB.PCI0.ACEL)
    {
        Method (CLRI, 0, Serialized)
        {
            If (_OSI ("Darwin"))
            {
                Local0 = Zero
                If ((^^LPCB.EC0.ECOK == One))
                {
                    If ((^^LPCB.EC0.SW2S == Zero))
                    {
                        If ((^^^BAT0._STA () == 0x1F))
                        {
                            If ((B1B2 (^^LPCB.EC0.BRM0, ^^LPCB.EC0.BRM1) <= 0x96))
                            {
                                Local0 = One
                            }
                        }
                    }
                }

                Return (Local0)
            }
            Else
            {
                Return (\_SB.PCI0.ACEL.XLRI ())
            }
        }
    }
    
    Scope (_SB.PCI0.LPCB.EC0)
    {
        Method (SMRD, 4, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                If (!ECOK)
                {
                    Return (0xFF)
                }

                If ((Arg0 != 0x07))
                {
                    If ((Arg0 != 0x09))
                    {
                        If ((Arg0 != 0x0B))
                        {
                            If ((Arg0 != 0x47))
                            {
                                If ((Arg0 != 0xC7))
                                {
                                    Return (0x19)
                                }
                            }
                        }
                    }
                }

                Acquire (MUT0, 0xFFFF)
                Local0 = 0x04
                While ((Local0 > One))
                {
                    SMST &= 0x40
                    SMCM = Arg2
                    SMAD = Arg1
                    SMPR = Arg0
                    Local3 = Zero
                    While (!Local1 = (SMST & 0xBF))
                    {
                        Sleep (0x02)
                        Local3++
                        If ((Local3 == 0x32))
                        {
                            SMST &= 0x40
                            SMCM = Arg2
                            SMAD = Arg1
                            SMPR = Arg0
                            Local3 = Zero
                        }
                    }

                    If ((Local1 == 0x80))
                    {
                        Local0 = Zero
                    }
                    Else
                    {
                        Local0--
                    }
                }

                If (Local0)
                {
                    Local0 = (Local1 & 0x1F)
                }
                Else
                {
                    If ((Arg0 == 0x07))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0x47))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0xC7))
                    {
                        Arg3 = SMB0 /* \_SB_.PCI0.LPCB.EC0_.SMB0 */
                    }

                    If ((Arg0 == 0x09))
                    {
                        Arg3 = B1B2 (MW00, MW00)
                    }

                    If ((Arg0 == 0x0B))
                    {
                        Local3 = BCNT /* \_SB_.PCI0.LPCB.EC0_.BCNT */
                        Local2 = 0x20
                        If ((Local3 > Local2))
                        {
                            Local3 = Local2
                        }

                        If ((Local3 < 0x09))
                        {
                            Local2 = RECB (0x04, 0x40)
                        }
                        ElseIf ((Local3 < 0x11))
                        {
                            Local2 = RECB (0x04, 0x80)
                        }
                        ElseIf ((Local3 < 0x19))
                        {
                            Local2 = RECB (0x04, 0xC0)
                        }
                        Else
                        {
                            Local2 = RECB (0x04, 0x0100)
                        }

                        Local3++
                        Local4 = Buffer (Local3){}
                        Local3--
                        Local5 = Zero
                        Name (OEMS, Buffer (0x46){})
                        ToBuffer (Local2, OEMS) /* \_SB_.PCI0.LPCB.EC0_.SMRD.OEMS */
                        While ((Local3 > Local5))
                        {
                            GBFE (OEMS, Local5, RefOf (Local6))
                            PBFE (Local4, Local5, Local6)
                            Local5++
                        }

                        PBFE (Local4, Local5, Zero)
                        Arg3 = Local4
                    }
                }

                Release (MUT0)
                Return (Local0)
            }
            Else
            {
                Return (\_SB.PCI0.LPCB.EC0.XMRD (Arg0, Arg1, Arg2, Arg3))
            }
        }
    }
    
    Scope (_SB.BAT0)
    {
        Method (UPBI, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Local5 = B1B2 (^^PCI0.LPCB.EC0.FCC0, ^^PCI0.LPCB.EC0.FCC1)
                If ((Local5 && !(Local5 & 0x8000)))
                {
                    Local5 >>= 0x05
                    Local5 <<= 0x05
                    PBIF [One] = Local5
                    PBIF [0x02] = Local5
                    Local2 = (Local5 / 0x64)
                    Local2 += One
                    Local4 = (Local2 * 0x0C)
                    PBIF [0x05] = (Local4 + 0x02)
                    Local4 = (Local2 * 0x07)
                    PBIF [0x06] = (Local4 + 0x02)
                    Local4 = (Local2 * 0x0A)
                    FABL = (Local4 + 0x02)
                }

                If (^^PCI0.LPCB.EC0.MBNH)
                {
                    Local0 = ^^PCI0.LPCB.EC0.BVLB /* \_SB_.PCI0.LPCB.EC0_.BVLB */
                    Local1 = ^^PCI0.LPCB.EC0.BVHB /* \_SB_.PCI0.LPCB.EC0_.BVHB */
                    Local1 <<= 0x08
                    Local0 |= Local1
                    PBIF [0x04] = Local0
                    PBIF [0x09] = "OANI$"
                    PBIF [0x0B] = "NiMH"
                }
                Else
                {
                    Local0 = ^^PCI0.LPCB.EC0.BVLB /* \_SB_.PCI0.LPCB.EC0_.BVLB */
                    Local1 = ^^PCI0.LPCB.EC0.BVHB /* \_SB_.PCI0.LPCB.EC0_.BVHB */
                    Local1 <<= 0x08
                    Local0 |= Local1
                    PBIF [0x04] = Local0
                    Sleep (0x32)
                    PBIF [0x0B] = "LION"
                }

                PBIF [0x09] = "Primary"
                UPUM ()
                PBIF [Zero] = One
            }
            Else
            {
                \_SB.BAT0.XPBI()
            }
        }
            
        Method (UPBS, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Local0 = B1B2 (^^PCI0.LPCB.EC0.CUR0, ^^PCI0.LPCB.EC0.CUR1)
                If ((Local0 & 0x8000))
                {
                    If ((Local0 == 0xFFFF))
                    {
                        PBST [One] = 0xFFFFFFFF
                    }
                    Else
                    {
                        Local1 = ~Local0
                        Local1++
                        Local3 = (Local1 & 0xFFFF)
                        PBST [One] = Local3
                    }
                }
                Else
                {
                    PBST [One] = Local0
                }

                Local5 = B1B2 (^^PCI0.LPCB.EC0.BRM0, ^^PCI0.LPCB.EC0.BRM1)
                If (!(Local5 & 0x8000))
                {
                    Local5 >>= 0x05
                    Local5 <<= 0x05
                    If ((Local5 != DerefOf (PBST [0x02])))
                    {
                        PBST [0x02] = Local5
                    }
                }

                If ((!^^PCI0.LPCB.EC0.SW2S && (^^PCI0.LPCB.EC0.BACR == One)))
                {
                    PBST [0x02] = FABL /* \_SB_.BAT0.FABL */
                }

                PBST [0x03] = B1B2 (^^PCI0.LPCB.EC0.BCV0, ^^PCI0.LPCB.EC0.BCV1)
                PBST [Zero] = ^^PCI0.LPCB.EC0.MBST /* \_SB_.PCI0.LPCB.EC0_.MBST */
            }
            Else
            {
                \_SB.BAT0.XPBS()
            }
        }
    }
}

