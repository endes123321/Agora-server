//Under GNU AGPL v3, see LICENCE
//Third-party code: haxe-hant by yar3333 under LGPL

package beartek.agora.server;

import datetime.DateTime;
import com.thomasuster.threadpool.ThreadPool;
import consoleout.ConsoleOut;
import hxIni.IniManager;

class Main_cli {
  var queque_cmd : String = '';
  var pool : ThreadPool = new ThreadPool(2);

  public function new() {
    Sys.println('Starting Agora web server.');

    haxe.Log.trace = this.trace;
    this.print_insert();

    this.config();
    Main.start();

    pool.addConcurrent(function( t : Int ) : Void {
      while( Main.on ) {
        try {
          Main.connection.refresh();
        } catch(e:String) {
          ConsoleOut.println('An error ocurred: ' + e, Color.Red, DisplayAttribute.Bold);
        } catch(e:Dynamic) {
          ConsoleOut.println('An unknow error ocurred: ' + Std.string(e), Color.Red, DisplayAttribute.Bold);
        }
        Sys.sleep(0.1);
      }
    });

    if( Sys.args()[0] != 'daemon' ) {
      pool.addConcurrent(function( t : Int ) : Void {
        while( Main.on ) {
          try {
            this.wait_for_command();
          } catch(e:Dynamic) {
            ConsoleOut.println('An error ocurred executing command: ' + e, Color.Red, DisplayAttribute.Bold);
            this.print_insert();
          }
        }
      });
    }

    pool.blockRunAll();
    pool.end();
    IniManager.writeToFile(Main.config, "agora.ini");
  }

  public function config() : Void {
    if( !sys.FileSystem.exists('agora.ini') ) {
      sys.io.File.saveContent('agora.ini', ' ');
    }
    Main.config = IniManager.loadFromFile("agora.ini");

    if( Main.config['connection'] == null ) Main.config['connection'] = new Map();
    if( Main.config['db'] == null ) Main.config['db'] = new Map();
    if( Main.config['secure'] == null ) Main.config['secure'] = new Map();

    if( Main.config['connection']['host'] == null ) Main.config['connection']['host'] = '0.0.0.0';
    if( Main.config['connection']['port'] == null ) Main.config['connection']['port'] = '8080';
    if( Main.config['connection']['max_clients'] == null ) Main.config['connection']['max_clients'] = '100';
    if( Main.config['db']['URI'] == null ) Main.config['db']['URI'] = 'sqlite://agora.db';
    IniManager.writeToFile(Main.config, "agora.ini");
  }

  public function wait_for_command() : Void {
    var cmd : String = this.readLine();
    if( cmd != '' ) {
      this.line_up(1);
      Sys.println("");

      var cmd_args : Array<String> = cmd.split(' ');
      cmd_args[0].toLowerCase();

      if( Main.handlers.commands.command(cmd_args) ) {
        this.back_to_column(0);
        ConsoleOut.print( 'Command executed sucesfull.', Color.Green );
      } else {
        ConsoleOut.print( 'Command not found.', Color.Yellow, DisplayAttribute.Reset );
      }

      this.print_insert();
    }
  }

  public inline function print_insert() : Void {
    var insert : String = ConsoleOut.textFormatCodes() + ConsoleOut.textFormatCodes(DisplayAttribute.Blink) + '❱ ' + ConsoleOut.textFormatCodes() + ConsoleOut.textFormatCodes(DisplayAttribute.Faint) + queque_cmd;
    Sys.print( "\r" + insert + " " + "\r" + insert );
  }

  public function trace( v:Dynamic, ?infos:haxe.PosInfos ) : Void {
    var color : Color = Color.White;
    if( infos.customParams != null ) {
      color = switch infos.customParams[0] {
      case 'info': Color.Blue;
      case 'warn': Color.Yellow;
      case 'error': Color.Red;
      case 'sucess': Color.Green;
      case _: Color.White;
      }
    }


    this.back_to_column(0);
    Sys.print(ConsoleOut.textFormatCodes());
    var str : String = '[' + DateTime.now().toString() + '][' + infos.className + ':' + infos.methodName + ']:' + Std.string(v);
    ConsoleOut.print("\r" + str + " " + "\r" + str, color, DisplayAttribute.Bold);
    this.print_insert();
  }

  private inline function back_to_column( n : Int ) : Void {
    Sys.print("\033[" + (2 + queque_cmd.length - n) + "D");
  }

  private function line_up( n : Int ) : Void {
    Sys.print("\033[" + n + "A");
  }

  private function line_down( n : Int ) : Void {
    Sys.print("\033[" + n + "B");
  }

  private function readLine(displayNewLineAtEnd=false) : String {
		while (true) {
			var c = Sys.getChar(false);
			if (c == 13) break;
			if (c == 8) {
				if (queque_cmd.length > 0) {
					queque_cmd = queque_cmd.substring(0, queque_cmd.length - 1);
					Sys.print(String.fromCharCode(8) + " " + String.fromCharCode(8));
				}
			} else if( c == 127 ) {
        if (queque_cmd.length > 0) {
					queque_cmd = queque_cmd.substring(0, queque_cmd.length - 1);
					Sys.print("\033[1D");
          Sys.print(" ");
          Sys.print("\033[1D");
				}
			} else {
				queque_cmd += String.fromCharCode(c);
				Sys.print(String.fromCharCode(c));
			}
		}
		if (displayNewLineAtEnd) Sys.println("");
    var s : String = queque_cmd;
    queque_cmd = '';
		return s;
	}

  static inline function main() : Void {
    new Main_cli();
  }

}
