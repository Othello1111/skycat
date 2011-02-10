# E.S.O. - VLT project/ ESO Archive
# "@(#) $Id: DialogWidget.tcl,v 1.1.1.1 2006/01/12 16:40:51 abrighto Exp $"
#
# DialogWidget.tcl - Base class of dialog widget classes
#
# who             when       what
# --------------  ---------  ----------------------------------------
# Allan Brighton  01 Jun 94  Created
# Peter W. Draper 03 Jul 06  Stop . being used as a parent, that is usually
#                            in a withdrawn state. Why hasn't this been a 
#                            problem before?
#                 21 Mar 07  Raise the window on activation. Keeps hiding.
#                 13 Apr 07  And wait for update 
#                 17 May 07  Make truncation lines an option.

itk::usual DialogWidget {}

# A DialogWidget is an itk widget for creating dialog windows.
# A dialog window here is a window with a message at top and a row 
# of buttons at bottom. Through inheritance, you can add widgets 
# inbetween.

itcl::class util::DialogWidget {
    inherit util::TopLevelWidget

    # create the dialog

    constructor {args} {
	set variable_ $w_.choice
	global ::$variable_

	wm iconname $w_ DialogWidget
        if {[winfo parent $w_] != "." } {
           wm transient $w_ [winfo parent $w_]
        }

	# The top frame has one frame for the message and bitmap
	# and another for extensions defined in derived classes.
	itk_component add top {
	    frame $w_.top -relief raised -borderwidth 2
	}

	# default frame (for image, bitmap, message...)
	itk_component add def {
	    frame $itk_component(top).def -borderwidth 2
	}

	# extension frame (for subclasses)
	itk_component add ext {
	    frame $itk_component(top).ext -borderwidth 2
	}
	pack  $itk_component(top) $itk_component(def) $itk_component(ext) \
	    -side top -fill both -expand 1


	# optional image frame
	itk_component add imagef {
	    frame $itk_component(def).imagef
	}
	# optional image label
	itk_component add image {
	    label $itk_component(imagef).image
	}

	# optional message text
	itk_component add text {
	    label $itk_component(def).text
	} {
	    keep -justify -background
	    rename -font -messagefont messageFont MessageFont
	    rename -wraplength -messagewidth messageWidth MessageWidth
	}

	# optional bitmap frame
	itk_component add bitmapf {
	    frame $itk_component(def).bitmapf
	}
	# optional bitmap label
	itk_component add bitmap {
	    label $itk_component(bitmapf).bitmap
	}

	pack $itk_component(imagef) -side top
	pack $itk_component(text) -side right -expand 1 -fill both -padx 5m -pady 5m
	pack $itk_component(bitmapf) -side left
	
	eval itk_initialize $args
    }


    # this method is called after the options have been evaluated

    protected method init {} {
	# truncate long (many lines) error mesages
	set err [split $itk_option(-text) \n]
	if {[llength $err] > $itk_option(-max_lines) } {
	    set err [lrange $err 0 $itk_option(-max_lines)]
	    lappend err "..."
	}
	set err [join $err \n]
	$itk_component(text) config -text $err

	# add optional buttons
	add_buttons
    }

    
    # Create a row of buttons at the bottom of the dialog.

    protected method add_buttons {} {
	# Button frame at bottom.
	itk_component add bot {
	    frame $w_.bot -relief raised -borderwidth 2
	}
	pack $itk_component(bot) -side bottom -fill x

	set i 0
	foreach but $itk_option(-buttons) {
	    # Components for buttons specified with the -buttons option.
	    # For example "buttonOK" for the OK button.
	    itk_component add button$i {
		button $itk_component(bot).button$i -text $but -command "set $variable_ $i"
	    } {
	    }
	    if {$i == $itk_option(-default)} {
		# Frame surrounding the default dialog button.
		itk_component add default {
		    frame $itk_component(bot).default -relief sunken -borderwidth 1
		}
		raise $itk_component(button$i) $itk_component(default)
		pack $itk_component(default) -side left -expand 1 -padx 3m -pady 2m
		pack $itk_component(button$i) -in $itk_component(default) -padx 2m -pady 2m \
			-ipadx 2m -ipady 1m
		bind $w_ <Return> "$itk_component(button$i) flash; $itk_component(button$i) invoke"
	    } else {
		pack $itk_component(button$i) -side left -expand 1 \
			-padx 3m -pady 3m -ipadx 2m -ipady 1m
	    }
	    incr i
	}
    }

    
    # Display the window and return the user's selection

    public method activate {} {
	global ::$variable_

	# Set a grab and claim the focus.

	set oldFocus [focus]
	if {$itk_option(-modal)} {
	    catch {grab $w_}
	}
        catch {::raise $w_}
        update idletasks
	tkwait visibility $w_
	if {$itk_option(-default) >= 0} {
	    focus $itk_component(button$itk_option(-default))
	} else {
	    focus $w_
	}

        # If the window is closed by the window manager we need to
        # get that request as well.
        wm protocol $w_ WM_DELETE_WINDOW "set ::$variable_ 0"

	# Wait for the user to respond, then restore the focus and
	# return the index of the selected button.

	tkwait variable $variable_
	set result [set_result]
	catch {unset $variable_}
	catch {destroy $w_}
	catch {focus $oldFocus}
	return $result
    }


    # this method may be redefined in a derived class to change the value
    # that is returned from activate (default is the number of the button selected)

    protected method set_result {} {
	global ::$variable_
	if {[info exists $variable_]} {
	    return [set $variable_]
	}
	return 0
    }


    # -- itk_option define -variables variables variables --

    # Title to display in dialog's decorative frame.
    itk_option define -title title Title {dialog} {
	wm title $w_ $itk_option(-title)
    }

    # Index of button that is to display the default ring (-1 means none).
    itk_option define -default default Default {0}

    # text of message (truncated if too long)
    itk_option define -text text Text {}
    
    # One or more strings to display in buttons across the
    # bottom of the dialog box.
    itk_option define -buttons buttons Buttons {OK}

    # optional image to display above the message
    itk_option define -image image Image {} {
	if {"$itk_option(-image)" != ""} {
	    $itk_component(image) config -image $itk_option(-image)
	    pack $itk_component(image) -padx 5m -pady 5m
	} else {
	    pack forget $itk_component(image)
	}
    }

    # optional bitmap to display to left of message
    itk_option define -bitmap bitmap Bitmap {info} {
	if {"$itk_option(-bitmap)" != ""} {
	    $itk_component(bitmap) config -bitmap $itk_option(-bitmap)
	    pack $itk_component(bitmap) -padx 5m -pady 5m
	} else {
	    pack forget $itk_component(bitmap)
	}
    }
    
    # flag: if true, grab the screen
    itk_option define -modal modal Modal 1
   
    # number of lines before truncation.
    itk_option define -max_lines max_lines Max_Lines 20

    # -- protected vars --

    # trace variable name
    protected variable variable_
}

