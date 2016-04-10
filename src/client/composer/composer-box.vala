/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

public class ComposerBox : Gtk.Frame, ComposerContainer {


    private ComposerWidget composer;
    private bool has_accel_group = false;
    
    public signal void vanished();
    
    public Gtk.Window top_window {
        get { return (Gtk.Window) get_toplevel(); }
    }
    
    public ComposerBox(ComposerWidget composer) {
        this.composer = composer;
        
        add(composer);
        composer.editor.focus_in_event.connect(on_focus_in);
        composer.editor.focus_out_event.connect(on_focus_out);
        show();
        
        get_style_context().add_class("geary-composer-box");

        if (composer.state == ComposerWidget.ComposerState.NEW) {
            composer.free_header();
            GearyApplication.instance.controller.main_window.main_toolbar.set_conversation_header(
                composer.header);
            get_style_context().add_class("geary-full-pane");
        }
    }
    
    public void remove_composer() {
        if (composer.editor.has_focus)
            on_focus_out();
        composer.editor.focus_in_event.disconnect(on_focus_in);
        composer.editor.focus_out_event.disconnect(on_focus_out);
        
        remove(composer);
        close_container();
    }
    
    
    private bool on_focus_in() {
        // For some reason, on_focus_in gets called a bunch upon construction.
        if (!has_accel_group)
            top_window.add_accel_group(composer.ui.get_accel_group());
        has_accel_group = true;
        return false;
    }
    
    private bool on_focus_out() {
        top_window.remove_accel_group(composer.ui.get_accel_group());
        has_accel_group = false;
        return false;
    }
    
    public void present() {
        top_window.present();
    }
    
    public unowned Gtk.Widget get_focus() {
        return top_window.get_focus();
    }
    
    public void vanish() {
        hide();
        if (get_style_context().has_class("geary-full-pane"))
            GearyApplication.instance.controller.main_window.main_toolbar.remove_conversation_header(
                composer.header);
        
        composer.state = ComposerWidget.ComposerState.DETACHED;
        composer.editor.focus_in_event.disconnect(on_focus_in);
        composer.editor.focus_out_event.disconnect(on_focus_out);

        vanished();
    }
    
    public void close_container() {
        if (visible)
            vanish();
    }
}

