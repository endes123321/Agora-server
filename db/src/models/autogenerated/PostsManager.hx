// This is autogenerated file. Do not edit!

package models.autogenerated;

class PostsManager
{
	var db : orm.Db;
	var orm : models.Orm;
	public var query(get, never) : orm.SqlQuery<models.Posts>;

	function get_query() : orm.SqlQuery<models.Posts>
	{
		return new orm.SqlQuery<models.Posts>("posts", db, this);
	}

	public function new(db:orm.Db, orm:models.Orm) : Void
	{
		this.db = db;
		this.orm = orm;
	}

	function newModelFromParams(id:String, content:String) : models.Posts
	{
		var _obj = new models.Posts(db, orm);
		_obj.id = id;
		_obj.content = content;
		return _obj;
	}

	function newModelFromRow(d:Dynamic) : models.Posts
	{
		var _obj = new models.Posts(db, orm);
		_obj.id = Reflect.field(d, 'id');
		_obj.content = Reflect.field(d, 'content');
		return _obj;
	}

	public function where(field:String, op:String, value:Dynamic) : orm.SqlQuery<models.Posts>
	{
		return query.where(field, op, value);
	}

	public function get(id:String) : models.Posts
	{
		return getBySqlOne('SELECT * FROM `posts` WHERE `id` = ' + db.quote(id));
	}

	public function create(id:String, content:String) : models.Posts
	{
		db.query('INSERT INTO `posts`(`id`, `content`) VALUES (' + db.quote(id) + ', ' + db.quote(content) + ')');
		return newModelFromParams(id, content);
	}

	public function createNamed(data:{ id:String, content:String }) : models.Posts
	{
		db.query('INSERT INTO `posts`(`id`, `content`) VALUES (' + db.quote(data.id) + ', ' + db.quote(data.content) + ')');
		return newModelFromParams(data.id, data.content);
	}

	public function createOptional(data:{ id:String, ?content:String }) : models.Posts
	{
		createOptionalNoReturn(data);
		return get(data.id);
	}

	public function createOptionalNoReturn(data:{ id:String, ?content:String }) : Void
	{
		var fields = [];
		var values = [];
		fields.push('`id`'); values.push(db.quote(data.id));
		if (Reflect.hasField(data, 'content')) { fields.push('`content`'); values.push(db.quote(data.content)); }
		db.query('INSERT INTO `posts`(' + fields.join(", ") + ') VALUES (' + values.join(", ") + ')');
	}

	public function delete(id:String) : Void
	{
		db.query('DELETE FROM `posts` WHERE `id` = ' + db.quote(id) + ' LIMIT 1');
	}

	public function getAll(_order:String=null) : Array<models.Posts>
	{
		return getBySqlMany('SELECT * FROM `posts`' + (_order != null ? ' ORDER BY ' + _order : ''));
	}

	public function getBySqlOne(sql:String) : models.Posts
	{
		var rows = db.query(sql + ' LIMIT 1');
		if (rows.length == 0) return null;
		return newModelFromRow(rows.next());
	}

	public function getBySqlMany(sql:String) : Array<models.Posts>
	{
		var rows = db.query(sql);
		var list : Array<models.Posts> = [];
		for (row in rows)
		{
			list.push(newModelFromRow(row));
		}
		return list;
	}
}