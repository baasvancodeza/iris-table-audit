ROUTINE csoftsc.PersistentAudit.Defines [Type=INC]

#define LeftPad(%Val,%PadLen,%PadChar)					$SELECT(%PadLen>0:$TRANSLATE($JUSTIFY($EXTRACT(%Val,1,%PadLen),%PadLen)," ",%PadChar),1:%Val)
