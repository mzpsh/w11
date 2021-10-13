using Gtk;
using Gdk;

public class App {
  public App(string Name, string Icon, string Exec) {
    name = Name;
    icon = Icon;
    exec = Exec;
  }
  public string name;
  public string icon;
  public string exec;
}

public class Launcher : Gtk.Window {
  public Launcher() {
    this.title = "Launcher";
    this.set_default_size(640, 640);
    this.set_position(Gtk.WindowPosition.CENTER);
    this.set_decorated(false);
    this.icon = new Gdk.Pixbuf.from_file_at_scale("img/icon.svg", 32, 32, false);
    this.destroy.connect(Gtk.main_quit);
    var screen = this.get_screen ();
    var css_provider = new Gtk.CssProvider();
    string path = "style.css";
    if (FileUtils.test (path, FileTest.EXISTS))
    {
      try {
        css_provider.load_from_path(path);
        Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
      } catch (Error e) {
        error ("Cannot load CSS stylesheet: %s", e.message);
      }
    }
    
    // new App( App name, App icon name, exec )
    App[] apps = {
      new App("Google Chrome", "google-chrome", "/opt/google/chromegoogle-chrome"),
      new App("Visual Studio Code", "visual-studio-code", "code"),
      new App("Firefox", "firefox", "firefox"),
      new App("fSpy", "fspy", "fspy"),
      new App("LXAppearance", "preferences-desktop-theme", "lxappearance"),
      new App("mpv", "mpv", "mpv"),
    };

    var mainBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    mainBox.get_style_context().add_class("main-box");
    mainBox.set_homogeneous(false);


    var launcherBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    launcherBox.get_style_context().add_class("launcher-box");

    var searchEntry = new Gtk.Entry();
    searchEntry.get_style_context().add_class("search-entry");
    searchEntry.set_icon_from_pixbuf(Gtk.EntryIconPosition.PRIMARY, new Gdk.Pixbuf.from_file_at_scale("img/search.svg", 16, 16, false));
    searchEntry.placeholder_text = "Type here to search";
    launcherBox.pack_start(searchEntry, false, false);

    var pinnedBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 32);
    pinnedBox.get_style_context().add_class("pinned-box");
    var pinnedLabel = new Gtk.Label("Pinned");
    pinnedLabel.get_style_context().add_class("pinned-label");
    var allAppsButton = new Gtk.Button.with_label("All apps >");
    allAppsButton.get_style_context().add_class("allapps-button");
    pinnedBox.pack_start(pinnedLabel, false, false);
    pinnedBox.pack_end(allAppsButton, false, false);
    launcherBox.pack_start(pinnedBox, false, false);


    var appsGrid = new Gtk.Grid();
    appsGrid.column_homogeneous = true;
    for(int i = 0; i < apps.length; i++) {
      App app = apps[i];
      var appButton = new Gtk.Button();
      appButton.get_style_context().add_class("app-button");
      var appBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
      var appIcon = new Gtk.Image.from_icon_name(app.icon, Gtk.IconSize.DND);
      var appLabel = new Gtk.Label(app.name);
      appBox.pack_start(appIcon, false, false);
      appBox.pack_start(appLabel, false, false);
      appButton.add(appBox);
      appButton.clicked.connect(() => {
        GLib.Process.spawn_command_line_sync(app.exec);
        this.iconify();
      });
      appsGrid.attach(appButton, i, 0);
    }
    launcherBox.pack_start(appsGrid, false, false);

    var userBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12);
    userBox.get_style_context().add_class("user-box");
    var userPictureWidget = new Gtk.Image.from_pixbuf(new Gdk.Pixbuf.from_file_at_scale("img/picture.png", 32, 32, false));
    userBox.pack_start(userPictureWidget, false, false);
    string name = "test";
    GLib.Process.spawn_command_line_sync("whoami", out name);
    stdout.printf(name + "\n");
    var userLabel = new Gtk.Label(name.strip());
    userBox.pack_start(userLabel, false, false);
    var powerPicture = new Gdk.Pixbuf.from_file_at_scale("img/power.svg", 16, 16, false);
    var powerPictureWidget = new Gtk.Image.from_pixbuf(powerPicture);
    var powerButton = new Gtk.Button();
    powerButton.get_style_context().add_class("power-button");
    powerButton.add(powerPictureWidget);
    userBox.pack_end(powerButton, false, false);

    mainBox.pack_start(launcherBox, true, true);
    mainBox.pack_end(userBox, false, false);

    this.add(mainBox);
    this.show_all();
    powerButton.grab_focus();
  }
}

int main(string[] args) {
  Gtk.init(ref args);
  new Launcher();
  Gtk.main();

  return 0;
}