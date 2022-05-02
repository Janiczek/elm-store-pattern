module UI exposing (a, button, h1, td, th)


td : String
td =
    "px-2 border-x border-y border-slate-200"


th : String
th =
    "px-2 bg-slate-100 border-t border-x border-slate-200"


h1 : String
h1 =
    "font-bold mb-2 border-b border-b-4 border-slate-200"


a : String
a =
    "underline text-sky-600"


button : String
button =
    "px-4 py-2 font-semibold text-sm bg-sky-500 hover:bg-sky-400 text-white rounded-none shadow-sm hover:shadow-md active:bg-sky-300"
