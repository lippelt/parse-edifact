'$Id$
Option Explicit

'------------------------------------------------------------------------------
Dim strFileName: strFileName = "..\Instances\ORDERS.D.97A.instance.Seagate.txt"
Dim stm: Set stm = CreateObject("ADODB.Stream")
stm.Open
stm.Type = 2 'Text
stm.Charset = "iso-8859-1"
stm.LoadFromFile strFileName

'---- ParseUNA ----------------------------------------------------------------
Dim cSegmentTerminator:             cSegmentTerminator             = Chr(39) ' '
Dim cDataElementSeparator:          cDataElementSeparator          = Chr(43) ' +
Dim cComponentDataElementSeparator: cComponentDataElementSeparator = Chr(58) ' :
Dim cReleaseCharacter:              cReleaseCharacter              = Chr(63) ' ?
If stm.ReadText(3) = "UNA" Then
  cComponentDataElementSeparator = stm.ReadText(1)
  cDataElementSeparator = stm.ReadText(1)
  stm.ReadText(1) 'DecimalNotation
  cReleaseCharacter = stm.ReadText(1)
  stm.ReadText(1) 'Reserved for future use, should contain a space
  cSegmentTerminator = stm.ReadText(1)
Else
  stm.Position = 0
End If

'---- Pre Parse EDIFACT -------------------------------------------------------
Dim xdoc: Set xdoc = CreateObject("MSXML2.FreeThreadedDOMDocument")
xdoc.async = False
xdoc.setProperty "SelectionLanguage", "XPath"
xdoc.loadXML "<F/>"

Dim cCurrent: cCurrent = ""
Dim cPreviousDelimiter: cPreviousDelimiter = cSegmentTerminator
Dim xnodF: Set xnodF = xdoc.documentElement
Dim xnodS: Set xnodS = Nothing
Dim xnodU: Set xnodU = Nothing
Dim strData: strData = ""
Dim n: n=0
Do Until stm.EOS
  cCurrent = stm.ReadText(1)
  Select Case cCurrent
    '------------------------------------------------------
    Case cReleaseCharacter
      strData = strData + stm.ReadText(1)
    '------------------------------------------------------
    Case cSegmentTerminator
      Select Case cPreviousDelimiter
        Case cSegmentTerminator
          nParsingError = 1
          Exit Do
        Case cDataElementSeparator
          Set xnodU = AddElement(xnodS, "U", "")
          AddElement xnodU, "V", strData
        Case cComponentDataElementSeparator
          AddElement xnodU, "V", strData
      End Select
      cPreviousDelimiter = cCurrent
      strData = ""
    '------------------------------------------------------
    Case cDataElementSeparator
      Select Case cPreviousDelimiter
        Case cSegmentTerminator
          n = n + 1
          Set xnodS = AddElement(xnodF, "S", "")
          xnodS.setAttribute "n", n
          AddElement xnodS, "N", Replace(strData, vbCrLf, "")
        Case cDataElementSeparator
          Set xnodU = AddElement(xnodS, "U", "")
          AddElement xnodU, "V", strData
        Case cComponentDataElementSeparator
          AddElement xnodU, "V", strData
      End Select
      cPreviousDelimiter = cCurrent
      strData = ""
    '------------------------------------------------------
    Case cComponentDataElementSeparator
      Select Case cPreviousDelimiter
        Case cSegmentTerminator
          nParsingError = 2
          Exit Do
        Case cDataElementSeparator
          Set xnodU = AddElement(xnodS, "U", "")
          AddElement xnodU, "V", strData
        Case cComponentDataElementSeparator
          AddElement xnodU, "V", strData
      End Select
      cPreviousDelimiter = cCurrent
      strData = ""
    '------------------------------------------------------
    Case Else
      strData = strData & CStr(cCurrent)
  End Select
Loop
stm.Close

xdoc.save strFileName & ".pre-parsed.xml"

WScript.Echo "Done."

Set xdoc = Nothing
Set stm = Nothing

'---- AddElement --------------------------------------------------------------
Private Function AddElement(ByRef xnodParentElement, strElementName, strElementText)
  Dim xnodAddedElement: Set xnodAddedElement = xdoc.createElement(strElementName)
  xnodParentElement.appendChild xnodAddedElement
  xnodAddedElement.text = strElementText
  Set AddElement = xnodAddedElement
End Function
