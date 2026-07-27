-- quickterm_settings.lua
-- Configuracion para quickterm.lua
--
-- Agrega o quita comandos segun tus necesidades.
-- Las categorias son solo para organizacion; internamente se aplanan
-- en una unica lista de deteccion.
--
-- Cuando se detecta uno de estos comandos, el panel quickterm se cierra
-- automaticamente. Para todo lo demas (CLI, TUI, scripts) el panel se
-- mantiene abierto para que puedas leer el output.

return {
  -- Lista de comandos que abren aplicaciones GUI.
  autoCloseable = {
    -- Editores / IDEs
    editors = {
      "idea",           -- IntelliJ IDEA
      "code",           -- Visual Studio Code
      "code-insiders",  -- VS Code Insiders
      "subl",           -- Sublime Text
      "zed",            -- Zed Editor
      "notepad++",      -- Notepad++
    },

    -- Control de versiones GUI
    git_gui = {
      "github",         -- GitHub Desktop
      "gk",             -- GitKraken
      "sourcetree",     -- Atlassian SourceTree
    },

    -- Herramientas de desarrollo / Utilidades GUI
    dev_tools = {
      "claude",         -- Claude Desktop
      "postman",        -- Postman
      "insomnia",       -- Insomnia
      "dockerdesktop",  -- Docker Desktop
    },

    -- Terminales / Emuladores
    terminals = {
      "wt",             -- Windows Terminal
      "wezterm",
      "wezterm-gui",
      "alacritty",
      "tabby",
    },

    -- Java ecosystem
    java = {
      "javaw",          -- Java launcher (sin consola)
      "jconsole",       -- Java Monitoring & Management Console
      "jvisualvm",      -- Java VisualVM
      "jaccessinspector",
      "jaccesswalker",
      "jabswitch",
    },

    -- Python
    python = {
      "pyw",            -- Python sin consola
      "pythonw",
    },

    -- Navegadores
    browsers = {
      "chrome",
      "firefox",
      "msedge",
      "brave",
      "opera",
      "vivaldi",
    },

    -- Aplicaciones del sistema Windows
    windows = {
      "explorer",       -- Explorador de archivos
      "notepad",        -- Bloc de notas
      "regedit",        -- Editor del registro
      "write",          -- WordPad
      "hh",             -- HTML Help
      "helppane",       -- Ayuda de Windows
      "winhlp32",       -- WinHelp
      "calc",           -- Calculadora
      "mspaint",        -- Paint
      "snippingtool",   -- Herramienta de recortes
    },

    -- Microsoft 365 / Apps de productividad
    microsoft = {
      "ms-teams",       -- Microsoft Teams
      "olk",            -- Outlook (nuevo)
      "mediaplayer",    -- Windows Media Player
      "microsoftstore", -- Microsoft Store
      "store",          -- Alias de Microsoft Store
      "gethelp",        -- App de Ayuda
      "gamebarelevatedft_alias", -- Xbox Game Bar
    },

    -- Testing / Performance
    testing = {
      "jmeterw",        -- Apache JMeter (modo GUI)
    },

    -- Process Lasso
    process_lasso = {
      "processlasso",
      "processlassolauncher",
      "cpu_eater",
      "insights",
      "logviewer",
      "quickupgrade",
      "threadracer",
      "tweakscheduler",
      "vistammsc",
      "uninstall",
    },
  },

  -- Flags que, si estan presentes en el comando completo,
  -- fuerzan a MANTENER el panel abierto (esperando Enter).
  -- Util cuando una GUI app bloquea la terminal (ej: code --wait).
  blockingFlags = {
    "--wait",
    "-w",
    "--block",
  },
}
