# E.S.O. - VLT project/ESO Archive
# @(#) $Id: skycat_defaults.tcl,v 1.1.1.1 2009/03/31 14:11:52 cguirao Exp $
#
# catdefaults.tcl - X defaults for itk catalog widgets
#
# who         when       what
# --------   ---------   ----------------------------------------------
# A.Brighton 20 May 96   created


# itk widget defaults (normally you'd put these in the itk sources, but
# putting them here makes it easier to "pre-load" the classes for the single
# binary version...

proc skycat::setXdefaults {} {
    option add *SkyCatCtrl.canvasBackground black 
    option add *SkyCatCtrl.canvasBackground black 
    option add *SkyCatCtrl.canvasWidth 520 
    option add *SkyCatCtrl.canvasHeight 520 

    option add *SkyQueryResult.relief sunken 
    option add *SkyQueryResult.borderwidth 3 
    option add *SkyQueryResult.font TkFixedFont
    option add *SkyQueryResult.headingFont TkDefaultFont
    option add *SkyQueryResult.headingLines 1 
    option add *SkyQueryResult.titleFont TkDefaultFont
}
