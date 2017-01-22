module Scintilla
  class ScintillaGtk < ScintillaBase
    attr_accessor :editor
#    def initialize
#      @editor = CFunc::call(CFunc::Pointer, "scintilla_new")
#    end
    
#    def send_message(message, w_param = 0, l_param = 0)
#      if !w_param.is_a?(String)
#        w_param = CFunc::UInt64(w_param)
##        $stderr.printf "w_param = %x\n", w_param.to_i
#      end
#      if !l_param.is_a?(String)
#        l_param = CFunc::SInt64(l_param)
#      end
#      ret = CFunc::call(CFunc::Int, "scintilla_send_message", @editor, 
#        CFunc::Int(message), w_param, l_param).to_i
#    end
    
    def sci_set_lexer_language(lang)
      send_message(Scintilla::SCI_SETLEXERLANGUAGE, 0, lang)
    end

    def sci_get_property(param)
      send_message_get_str(Scintilla::SCI_GETPROPERTY, param)
    end
    
    def sci_get_line(param)
      send_message_get_str(Scintilla::SCI_GETLINE, param)
    end
    
  end
end
