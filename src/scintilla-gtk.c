#include <stdio.h>
#include <stdlib.h>
#include "mruby.h"
#include "mruby/class.h"
#include "mruby/data.h"
#include "mruby/string.h"
#include "mruby/array.h"
#include "mruby/variable.h"

#include <gtk/gtk.h>

#include "Scintilla.h"
#define PLAT_GTK 1
#include "ScintillaWidget.h"

#define DONE mrb_gc_arena_restore(mrb, 0)


static mrb_state *scmrb;

struct mrb_scintilla_data {
  GtkWidget *view;
  mrb_value view_obj;
  struct mrb_scintilla_data *next;
};

struct mrb_scintilla_doc_data {
  sptr_t pdoc;
};

static struct mrb_scintilla_data *scintilla_list = NULL;

static void scintilla_gtk_free(mrb_state *mrb, void *ptr) {
  fprintf(stderr, "scintilla_gtk_free %p\n", ptr);
  if (ptr != NULL) {
    //	  scintilla_delete(ptr);
  }
}

const static struct mrb_data_type mrb_scintilla_gtk_type = { "ScintillaGtk", scintilla_gtk_free };

const static struct mrb_data_type mrb_document_type = { "Document", mrb_free };

#if 0
static mrb_value
mrb_scintilla_gtk_initialize(mrb_state *mrb, mrb_value self)
{
  GtkWidget *editor;
  mrb_value gtk_app;
  struct mrb_scintilla_data *scdata = malloc(sizeof(struct mrb_scintilla_data));
  struct mrb_scintilla_data *tmp;
  mrb_int argc;

  editor = scintilla_new();
  /*  argc = mrb_get_args(mrb, "|o", &gtk_app);
  fprintf(stderr, "class name = %s\n", mrb_obj_classname(mrb, gtk_app));
  */
  DATA_TYPE(self) = &mrb_scintilla_gtk_type;
  DATA_PTR(self) = editor;
  scdata->view = editor;
  scdata->view_obj = self;
  scdata->next = NULL;

  if (scintilla_list == NULL) {
    scintilla_list = scdata;
  } else {
    tmp = scintilla_list;
    while (tmp->next != NULL) {
      tmp = tmp->next;
    }
    tmp->next = scdata;
  }
  return self;
}

static mrb_value
mrb_scintilla_gtk_send_message(mrb_state *mrb, mrb_value self)
{
  GtkWidget *editor = DATA_PTR(self);
  sptr_t ret;
  mrb_int i_message, argc;
  uptr_t w_param = 0;
  sptr_t l_param = 0;
  mrb_value w_param_obj, l_param_obj;

  argc = mrb_get_args(mrb, "i|oo", &i_message, &w_param_obj, &l_param_obj);
  if (i_message < SCI_START) {
    mrb_raise(mrb, E_ARGUMENT_ERROR, "invalid message");
    return mrb_nil_value();
  }
  if (argc > 1) {
    switch(mrb_type(w_param_obj)) {
    case MRB_TT_FIXNUM:
      w_param = (uptr_t)mrb_fixnum(w_param_obj);
      break;
    case MRB_TT_STRING:
      w_param = (uptr_t)mrb_string_value_ptr(mrb, w_param_obj);
      break;
    case MRB_TT_TRUE:
      w_param = TRUE;
      break;
    case MRB_TT_FALSE:
      w_param = FALSE;
      break;
    case MRB_TT_UNDEF:
      w_param = 0;
      break;
    default:
      mrb_raise(mrb, E_ARGUMENT_ERROR, "invalid parameter");
      return mrb_nil_value();
    }
  }
  if (argc > 2) {
    switch(mrb_type(l_param_obj)) {
    case MRB_TT_FIXNUM:
      l_param = (sptr_t)mrb_fixnum(l_param_obj);
      break;
    case MRB_TT_STRING:
      l_param = (sptr_t)mrb_string_value_ptr(mrb, l_param_obj);
      break;
    case MRB_TT_TRUE:
      l_param = TRUE;
      break;
    case MRB_TT_FALSE:
      l_param = FALSE;
      break;
    case MRB_TT_UNDEF:
      l_param = 0;
      break;
    default:
      mrb_raise(mrb, E_ARGUMENT_ERROR, "invalid parameter");
      return mrb_nil_value();
    }
  }

  ret = scintilla_send_message(SCINTILLA(editor), i_message, w_param, l_param);
  /*
    if (i_message == SCI_SETPROPERTY) {
    fprintf(stderr, "w_param = %s, l_param = %s\n", w_param, l_param);
    }
  */
  return mrb_fixnum_value(ret);
}
#endif

mrb_mruby_scintilla_gtk_gem_init(mrb_state* mrb)
{
  struct RClass *sci, *scim, *doc;
  scim = mrb_module_get(mrb, "Scintilla");

/*
  sci = mrb_define_class_under(mrb, scim, "ScintillaGtk", mrb_class_get_under(mrb, scim, "ScintillaBase"));
  MRB_SET_INSTANCE_TT(sci, MRB_TT_DATA);
  mrb_define_method(mrb, sci, "send_message", mrb_scintilla_gtk_send_message, MRB_ARGS_ARG(1, 2));

  doc = mrb_define_class_under(mrb, scim, "Document", mrb->object_class);
  MRB_SET_INSTANCE_TT(doc, MRB_TT_DATA);
  mrb_define_method(mrb, sci, "initialize", mrb_scintilla_gtk_initialize, MRB_ARGS_NONE());

  scmrb = mrb;
*/
  /* platform */
#if defined(__APPLE__)
  mrb_define_const(mrb, scim, "PLATFORM", mrb_symbol_value(mrb_intern_cstr(mrb, "GTK_MACOSX")));
#elif defined(__WIN_32__) || defined(_MSC_VER)
  mrb_define_const(mrb, scim, "PLATFORM", mrb_symbol_value(mrb_intern_cstr(mrb, "GTK_WIN32")));
#else
  mrb_define_const(mrb, scim, "PLATFORM", mrb_symbol_value(mrb_intern_cstr(mrb, "GTK")));
#endif  
  

  DONE;
}

void
mrb_mruby_scintilla_gtk_gem_final(mrb_state* mrb)
{
}
