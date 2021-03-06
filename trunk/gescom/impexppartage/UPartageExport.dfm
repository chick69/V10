object FExportData: TFExportData
  Left = 492
  Top = 255
  Width = 923
  Height = 572
  Caption = 'Export des partages'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Dock971: TDock97
    Left = 0
    Top = 498
    Width = 907
    Height = 35
    AllowDrag = False
    Position = dpBottom
    object PBouton: TToolWindow97
      Left = 0
      Top = 0
      ClientHeight = 31
      ClientWidth = 907
      Caption = 'Barre outils fiche'
      ClientAreaHeight = 31
      ClientAreaWidth = 907
      DockPos = 0
      FullSize = True
      TabOrder = 0
      DesignSize = (
        907
        31)
      object BFerme: TToolbarButton97
        Left = 843
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Fermer'
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Cancel = True
        Flat = False
        ModalResult = 2
        OnClick = BFermeClick
        GlobalIndexImage = 'Z0021_S16G1'
      end
      object HelpBtn: TToolbarButton97
        Left = 875
        Top = 2
        Width = 28
        Height = 27
        Hint = 'Aide'
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Flat = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        Spacing = -1
        GlobalIndexImage = 'Z1117_S16G1'
        IsControl = True
      end
    end
  end
  object HPanel1: THPanel
    Left = 0
    Top = 0
    Width = 907
    Height = 41
    Align = alTop
    FullRepaint = False
    TabOrder = 1
    BackGroundEffect = bdFlat
    ColorShadow = clWindowText
    ColorStart = clBtnFace
    TextEffect = tenone
    object LNomDB: THLabel
      Left = 327
      Top = 12
      Width = 73
      Height = 13
      Caption = 'Base Principale'
    end
    object LBBaseRef: THLabel
      Left = 623
      Top = 13
      Width = 35
      Height = 13
      Caption = 'XXXXX'
    end
    object HLabel1: THLabel
      Left = 13
      Top = 12
      Width = 55
      Height = 13
      Caption = 'Serveur DB'
    end
    object BConnect: TToolbarButton97
      Left = 279
      Top = 7
      Width = 24
      Height = 24
      Hint = 'Se connecter'
      ParentShowHint = False
      ShowHint = True
      OnClick = BConnectClick
      GlobalIndexImage = 'O0117_S24G1'
    end
    object DBNAME: THValComboBox
      Left = 409
      Top = 8
      Width = 199
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      TagDispatch = 0
    end
    object SERVERNAME: TEdit
      Left = 80
      Top = 8
      Width = 193
      Height = 21
      TabOrder = 1
    end
  end
  object HPanel2: THPanel
    Left = 0
    Top = 41
    Width = 321
    Height = 409
    Align = alLeft
    FullRepaint = False
    TabOrder = 2
    BackGroundEffect = bdFlat
    ColorShadow = clWindowText
    ColorStart = clBtnFace
    TextEffect = tenone
  end
  object HPanel3: THPanel
    Left = 321
    Top = 41
    Width = 586
    Height = 409
    Align = alClient
    FullRepaint = False
    TabOrder = 3
    BackGroundEffect = bdFlat
    ColorShadow = clWindowText
    ColorStart = clBtnFace
    TextEffect = tenone
  end
  object HPanel4: THPanel
    Left = 0
    Top = 450
    Width = 907
    Height = 48
    Align = alBottom
    FullRepaint = False
    TabOrder = 4
    BackGroundEffect = bdFlat
    ColorShadow = clWindowText
    ColorStart = clBtnFace
    TextEffect = tenone
    object LbSaveFile: THLabel
      Left = 16
      Top = 13
      Width = 142
      Height = 13
      Caption = 'Nom du fichier de sauvegarde'
    end
    object BLanceExport: TToolbarButton97
      Left = 424
      Top = 8
      Width = 24
      Height = 24
      OnClick = BLanceExportClick
      GlobalIndexImage = 'O0035_S24G1'
    end
    object SaveFileName: THCritMaskEdit
      Left = 168
      Top = 10
      Width = 233
      Height = 21
      AutoSize = False
      TabOrder = 0
      TagDispatch = 0
      ElipsisButton = True
      OnElipsisClick = SaveFileNameElipsisClick
    end
  end
  object SaveFile: TSaveDialog
    DefaultExt = '*.CLP'
    Left = 472
    Top = 458
  end
end
