module translations;

private immutable string[string] translationDictionary;

shared static this() {
    import core.stdc.locale: setlocale, LC_ALL;
    import std.string:       fromStringz, startsWith;

    const auto locale = fromStringz(setlocale(LC_ALL, ""));

    if (startsWith(locale, "es")) {
        translationDictionary = [
            "History"                       : "Historial",
            "Clear Today's History"         : "Borrar el historial de hoy",
            "Clear All History"             : "Borrar todo el historial",
            "Preferences"                   : "Ajustes",
            "About Mantissa"                : "Acerca de Mantissa",
            "Security Info"                 : "Información sobre seguridad",
            "Close"                         : "Cerrar",
            "This resource is safe!"        : "Este recurso es seguro",
            "This resource is not safe!"    : "Este recurso no es seguro",
            "Open File"                     : "Abrir archivo",
            "Visit"                         : "Visitar",
            "Search"                        : "Buscar",
            "Enable Smooth Scrolling"       : "Habilitar desplazamiento Suave",
            "Enable Page Caching"           : "Habilitar cacheo de paginas web",
            "Enable JavaScript Support"     : "Habilitar soporte para JavaScript",
            "Enable Site-Specific Quirks"   : "Habilitiar retoques para sitios",
            "Keep Cookies Between Sessions" : "Guardar cookies al final de la sesión",
            "Force HTTPS Navigation"        : "Forzar uso de HTTPS",
            "Allow Insecure Content On HTTPS" : "Permitir contenido no seguro en HTTPS",
            "Use GTK's Header Bar"          : "Usar la barra de cabezera de GTK",
            "Engine Settings"               : "Ajustes del motor de renderizado",
            "Homepage"                      : "Página principal",
            "Search Engine"                 : "Buscador",
            "Cookie Policy"                 : "Política de cookies",
            "New Private Tab"               : "Abrir pestaña privada",
            "Accept all cookies" : "Aceptar todas las cookies",
            "Reject all cookies" : "No aceptar ninguna cookie",
            "Accept only cookies set by the main site" : "Solo aceptar cookies del sitio principal",
            "Browser Settings" : "Ajustes del navegador",
            "Appearance" : "Apariencia",
            "Your connection with this resource is secure, your data cannot be stolen"   : "La conexión con este recurso es segura, tus datos no pueden ser robados",
            "Your connection with this resource is unsecure, your data could be stolen!" : "La conexión con este recurso no es segura, tus datos podrían ser robados",
            "Please search for secure alternatives, or contact the site's webmasters"    : "Por favor busca alternativas seguras, o contacta los dueños del sitio"
        ];
    } else if (startsWith(locale, "it")) {
        translationDictionary = [
            "History"                       : "Cronologia",
            "Clear Today's History"         : "Cancella la cronologia di oggi",
            "Clear All History"             : "Cancella tutta la cronologia",
            "Preferences"                   : "Impostazioni",
            "About Mantissa"                : "Informazioni su Mantissa",
            "Security Info"                 : "Informazioni di sicurezza",
            "Close"                         : "Chiudi",
            "This resource is safe!"        : "Risorsa sicura",
            "This resource is not safe!"    : "Risorsa non sicura",
            "Open File"                     : "Apri file",
            "Visit"                         : "Visita",
            "Search"                        : "Cerca",
            "Enable Smooth Scrolling"       : "Abilita scorrimento fluido",
            "Enable Page Caching"           : "Abilita cache delle pagine web",
            "Enable JavaScript Support"     : "Abilita JavaScript",
            "Enable Site-Specific Quirks"   : "Abilita aggiustamenti per siti specifici",
            "Keep Cookies Between Sessions" : "Conserva i cookie tra le sessioni",
            "Force HTTPS Navigation"        : "Forza HTTPS",
            "Allow Insecure Content On HTTPS" : "Permetti contenuti non sicuri in HTTPS",
            "Use GTK's Header Bar"          : "Usa la barra del titolo di GTK",
            "Engine Settings"               : "Impostazioni del motore di rendering",
            "Homepage"                      : "Pagina iniziale",
            "Search Engine"                 : "Motore di ricerca",
            "Cookie Policy"                 : "Gestione cookie",
            "New Private Tab"               : "Nuova scheda privata",
            "Accept all cookies" : "Accetta tutti i cookie",
            "Reject all cookies" : "Rifiuta tutti i cookie",
            "Accept only cookies set by the main site" : "Accetta solo cookie dal sito principale",
            "Browser Settings" : "Impostazioni del browser",
            "Appearance" : "Aspetto",
            "Your connection with this resource is secure, your data cannot be stolen"   : "La connessione è sicura, i tuoi dati sono protetti",
            "Your connection with this resource is unsecure, your data could be stolen!" : "La connessione non è sicura, i tuoi dati sono a rischio",
            "Please search for secure alternatives, or contact the site's webmasters"    : "Cerca delle alternative o contatta l'amministratore del sito"
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
