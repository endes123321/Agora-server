// This is autogenerated file. Do not edit!

package models.autogenerated;

class Loginkey
{
	var db : orm.Db;
	var orm : models.Orm;
	public var key : String;
	public var user_id : String;

	public function new(db:orm.Db, orm:models.Orm) : Void
	{
		this.db = db;
		this.orm = orm;
	}

	public function set(user_id:String) : Void
	{
		this.user_id = user_id;
	}

	public function save() : Void
	{
		db.query(
			 'UPDATE `loginkey` SET '
				+  '`user_id` = ' + db.quote(user_id)
			+' WHERE `key` = ' + db.quote(key)
			+' LIMIT 1'
		);
	}
}