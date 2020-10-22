module backend.translations;

private immutable string[string] translationDictionary;

shared static this() {
    import core.stdc.locale: setlocale, LC_ALL;
    import std.string:       fromStringz, startsWith;

    const auto locale = fromStringz(setlocale(LC_ALL, ""));

    if (startsWith(locale, "es")) {
        translationDictionary = [
            "History"                       : "Historial",
            "Clear Today's History"         : "Borrar el Historial De Hoy",
            "Clear All History"             : "Borrar Todo el Historial",
            "Preferences"                   : "Ajustes",
            "About Mantissa"                : "Acerca de Mantissa",
            "Security Info"                 : "Información Sobre Seguridad",
            "Close"                         : "Cerrar",
            "This resource is safe!"        : "Este recurso es seguro",
            "This resource is not safe!"    : "Este recurso no es seguro!",
            "Open File"                     : "Abrir Archivo",
            "Visit"                         : "Visitar",
            "Search"                        : "Buscar",
            "Enable Smooth Scrolling"       : "Habilitar Desplazamiento Suave",
            "Enable Page Caching"           : "Habilitar Cacheo de Recursos",
            "Enable Javascript Support"     : "Habilitar Soporte para Javascript",
            "Enable Site-Specific Quirks"   : "Habilitiar Retoques para Sitios",
            "Keep Cookies Between Sessions" : "Guardar Cookies al Final de la Sesión",
            "Force HTTPS Navigation"        : "Forzar Uso de HTTPS",
            "Allow Insecure Content On HTTPS" : "Permitir Contenido No Seguro en HTTPS",
            "Use GTK's Header Bar"          : "Usar la Barra de Cabezera de GTK",
            "Engine Settings"               : "Ajustes del Motor de Renderizado",
            "Homepage"                      : "Pagina principal",
            "Search Engine"                 : "Buscador",
            "Cookie Policy"                 : "Política de Cookies",
            "Accept all cookies unconditionally" : "Aceptar todas las cookies",
            "Reject all cookies unconditionally" : "No aceptar ninguna cookie",
            "Accept only cookies set by the main site" : "Solo aceptar cookies del sitio principal",
            "Browser Settings" : "Ajustes del Navegador",
            "Appearance" : "Apariencia",
            "Your connection with this resource is secure, your data cannot be stolen"   : "Tu conexión con este recurso es segura, tus datos no pueden ser robados",
            "Your connection with this resource is unsecure, your data could be stolen!" : "Tu conexión con este recurso no es segura, tus datos podrían ser robados",
            "Please search for secure alternatives, or contact the site's webmasters"    : "Por favor busca alternativas seguras, o contacta los dueños del sitio"
        ];
    } else if (startsWith(locale, "it")) {
        translationDictionary = [
            "History"                       : "Cronologia",
            "Clear Today's History"         : "Cancella la Cronologia di Oggi",
            "Clear All History"             : "Cancella Tutta la Cronologia",
            "Preferences"                   : "Impostazioni",
            "About Mantissa"                : "Informazioni su Mantissa",
            "Security Info"                 : "Informazioni di Sicurezza",
            "Close"                         : "Chiudi",
            "This resource is safe!"        : "Questa risorsa è sicura!",
            "This resource is not safe!"    : "Questa risorsa non è sicura!",
            "Open File"                     : "Apri File",
            "Visit"                         : "Visita",
            "Search"                        : "Cerca",
            "Enable Smooth Scrolling"       : "Abilita Scroll Fluido",
            "Enable Page Caching"           : "Abilita Cache delle Pagine Web",
            "Enable Javascript Support"     : "Abilita Supporto Javascript",
            "Enable Site-Specific Quirks"   : "Abilita Peculiarità Specifiche per Siti",
            "Keep Cookies Between Sessions" : "Conserva i Cookie tra le Sessioni",
            "Force HTTPS Navigation"        : "Forza navigazione HTTPS",
            "Allow Insecure Content On HTTPS" : "Permettere Contenuti non Sicuri su HTTPS",
            "Use GTK's Header Bar"          : "Usa la Barra del Titolo di GTK",
            "Engine Settings"               : "Impostazioni del Motore di Rendering",
            "Homepage"                      : "Home Page",
            "Search Engine"                 : "Motore di Ricerca",
            "Cookie Policy"                 : "Gestione dei Cookie",
            "Accept all cookies unconditionally" : "Accetta Incondizionatamente Tutti i Cookie",
            "Reject all cookies unconditionally" : "Rifiuta Incondizionatamente Tutti i Cookie",
            "Accept only cookies set by the main site" : "Accetta Solo i Cookie Impostati dal Sito Principale",
            "Browser Settings" : "Impostazioni del Browser",
            "Appearance" : "Aspetto",
            "Your connection with this resource is secure, your data cannot be stolen"   : "La tua connessione con questa risorsa è sicura, i tuoi dati non possono essere rubati",
            "Your connection with this resource is unsecure, your data could be stolen!" : "La tua connessione con questa risorsa non è sicura, i tuoi dati potrebbero essere rubati!",
            "Please search for secure alternatives, or contact the site's webmasters"    : "Cerca alternative sicure o contatta gli amministratori del sito"
        ];
    }
}

/**
 * Get translation for the argument.
 */
string _(string msg) {
    if (msg in translationDictionary) {
        return translationDictionary[msg];
    }

    return msg;
}
