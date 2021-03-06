//Under GNU AGPL v3, see LICENCE

package beartek.agora.server;

import beartek.utils.Wtps;
import beartek.utils.Wtp_types;
import beartek.agora.types.Protocol_types;
import beartek.agora.types.Types;
import beartek.agora.types.Tpost;
import beartek.agora.types.Tid;
import beartek.agora.types.Tuser_info;
import beartek.agora.types.Tsentence;


class Protocol extends Wtps {
  var get_handlers : Map<String,Array<Int -> String -> Dynamic -> Void>> = new Map();
  var create_handlers : Map<String,Array<Int -> String -> Dynamic -> Void>> = new Map();
  var remove_handlers : Map<String,Array<Int -> String -> Dynamic -> Void>> = new Map();

  var join_handlers : Array<Int -> Void> = new Array();
  var left_handlers : Array<Int -> Void> = new Array();

  public function new(host : String, port: Int = 8080, max: Int = 100, ?secure_path : {CA: String, Certificate: String, Key: String}, debug : Bool = true) {
    super(host, port, max, secure_path, debug);
  }

  override public function on_new_client( id : Int ) : Void {
    for( func in join_handlers ) {
      func(id);
    }
  }

  override public function on_client_left( id : Int ) : Void {
    for( func in left_handlers ) {
      func(id);
    }
  }

  override public function on_pet( client_id : Int, pet : {id: String, type: Pet_types, data: Dynamic} ) : Void {
    switch pet.type {
    case Get(d): this.process(get_handlers, client_id, pet.id, d, pet.data);
    case Create(d): this.process(create_handlers, client_id, pet.id, d, pet.data);
    case Remove(d): this.process(remove_handlers, client_id, pet.id, d, pet.data);
    }
  }

  private function process(handlers : Map<String,Array<Int -> String -> Dynamic -> Void>>, client_id : Int, pet_id : String, type : String, data: Dynamic) : Void {
    if( handlers[type] != null ) {
      for( func in handlers[type] ) {
        #if debug
        var stamp : Float = haxe.Timer.stamp();
        this.execute_handler(func, client_id, pet_id, type, data);
        trace( 'Handler executed in '  + (haxe.Timer.stamp() - stamp)*1000 + ' ms', 'info');
        #else
        this.execute_handler(func, client_id, pet_id, type, data);
        #end
      }
    } else {
      trace( 'No handlers to process msg', 'error' );
      Main.connection.send_error({type: 4, msg: 'Unknow msg type'}, client_id, pet_id);
    }
  }

  private function execute_handler( ?func: Int -> String -> Dynamic -> Void, client_id : Int, pet_id : String, type : String, ?data: Dynamic ) : Void {
    try {
      func(client_id, pet_id, data);
    } catch(e:Dynamic) {
      trace('Error executing handler for ' + pet_id + ' of type ' + type + ': ' + e, 'error');
      trace( haxe.CallStack.toString(haxe.CallStack.exceptionStack()), 'error' );
      if( Std.is(e.type, Int) ) {
        Main.connection.send_error(e, client_id, pet_id);
      } else {
        Main.connection.send_error({type: 0, msg: 'Unknow error'}, client_id, pet_id);
      }
    }
  }

  public inline function register_get_handler( for_type : String, ?func: Int -> String -> Dynamic -> Void ) : Void {
    if(get_handlers[for_type] != null) get_handlers[for_type].push(func) else get_handlers[for_type] = [func];
  }

  public inline function register_create_handler( for_type : String, func: Int -> String -> Dynamic -> Void ) : Void {
    if(create_handlers[for_type] != null) create_handlers[for_type].push(func) else create_handlers[for_type] = [func];
  }

  public inline function register_remove_handler( for_type : String, func: Int -> String -> Dynamic -> Void ) : Void {
    if(remove_handlers[for_type] != null) remove_handlers[for_type].push(func) else remove_handlers[for_type] = [func];
  }

  public inline function register_join_handler( func: Int -> Void ) : Void {
    join_handlers.push(func);
  }

  public inline function register_left_handler( func: Int -> Void ) : Void {
    left_handlers.push(func);
  }

  public function create_sender( send_func : Dynamic -> Int -> String -> Void, handler : Dynamic -> Dynamic ) : Int -> String -> Dynamic -> Void {
    return function ( client : Int, conn : String, data : Dynamic ) : Void {
      send_func(handler(data), client, conn);
    }
  }

  public inline function send_privkey( privkey : haxe.io.ArrayBufferView, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'privkey', privkey.buffer, conn);
  }

  public inline function send_token( token : haxe.io.Bytes, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'token', token, conn);
  }

  public inline function send_auth( auth : Bool = true, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'auth', auth, conn);
  }

  public inline function send_post( post : Tpost, client : Int, ?conn : String ) : Void {
    if( post.is_full() ) {
      this.send_response(client, 'full_post', post, conn);
    } else {
      this.send_response(client, 'post', post, conn);
    }
  }

  public inline function send_post_id( id : Tid, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'post_id', id, conn);
  }

  public inline function send_post_removed( removed : Bool = true, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'post_removed', removed, conn);
  }

  public inline function send_sentence_id( id : Tid, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'sentence_id', id, conn);
  }

  public inline function send_sentence( sentence : Tsentence, client : Int, ?conn : String ) : Void {
    if( sentence.is_draft() ) {
      throw 'Only complete sentence can be send to the client';
    } else {
      this.send_response(client, 'sentence', sentence, conn);
    }
  }

  public inline function send_sentence_removed( removed : Bool = true, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'sentence_removed', removed, conn);
  }

  public inline function send_search_result( result : Search_results, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'search_result', result, conn);
  }


  public inline function send_user_info( user : Tuser_info, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'user_info', user, conn);
  }

  public inline function send_error( error: Error, client : Int, ?conn : String ) : Void {
    this.send_response(client, 'error', error, conn);
  }
}
