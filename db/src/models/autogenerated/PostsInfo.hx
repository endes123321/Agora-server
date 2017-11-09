// This is autogenerated file. Do not edit!

package models.autogenerated;

class PostsInfo
{
	var db : orm.Db;
	var orm : models.Orm;
	public var id : String;
	public var title : String;
	public var subtitle : String;
	public var overview : String;
	public var author_id : String;
	public var publish_date : Float;
	public var edit_date : Float;
	public var day_popularity : Int;
	public var total_popularity : Int;
	public var last_access : Float;

	public function new(db:orm.Db, orm:models.Orm) : Void
	{
		this.db = db;
		this.orm = orm;
	}

	public function set(title:String, subtitle:String, overview:String, author_id:String, publish_date:Float, edit_date:Float, day_popularity:Int, total_popularity:Int, last_access:Float) : Void
	{
		this.title = title;
		this.subtitle = subtitle;
		this.overview = overview;
		this.author_id = author_id;
		this.publish_date = publish_date;
		this.edit_date = edit_date;
		this.day_popularity = day_popularity;
		this.total_popularity = total_popularity;
		this.last_access = last_access;
	}

	public function save() : Void
	{
		db.query(
			 'UPDATE `posts_info` SET '
				+  '`title` = ' + db.quote(title)
				+', `subtitle` = ' + db.quote(subtitle)
				+', `overview` = ' + db.quote(overview)
				+', `author_id` = ' + db.quote(author_id)
				+', `publish_date` = ' + db.quote(publish_date)
				+', `edit_date` = ' + db.quote(edit_date)
				+', `day_popularity` = ' + db.quote(day_popularity)
				+', `total_popularity` = ' + db.quote(total_popularity)
				+', `last_access` = ' + db.quote(last_access)
			+' WHERE `id` = ' + db.quote(id)
			+' LIMIT 1'
		);
	}
}