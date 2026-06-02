package com.conservatio.db

import app.cash.sqldelight.Query
import app.cash.sqldelight.TransacterImpl
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlCursor
import app.cash.sqldelight.db.SqlDriver
import kotlin.Any
import kotlin.Double
import kotlin.Long
import kotlin.String

public class ConservationObjectQueries(
  driver: SqlDriver,
) : TransacterImpl(driver) {
  public fun <T : Any> selectAll(mapper: (
    id: String,
    title: String,
    object_type: String,
    materials: String,
    height: Double?,
    width: Double?,
    depth: Double?,
    diameter: Double?,
    weight: Double?,
    measurement_unit: String?,
    owner_name: String?,
    location_description: String?,
    acquisition_date: Long?,
    inventory_number: String?,
    description: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(-796_653_207, arrayOf("ConservationObjectEntity"), driver,
      "ConservationObject.sq", "selectAll",
      "SELECT ConservationObjectEntity.id, ConservationObjectEntity.title, ConservationObjectEntity.object_type, ConservationObjectEntity.materials, ConservationObjectEntity.height, ConservationObjectEntity.width, ConservationObjectEntity.depth, ConservationObjectEntity.diameter, ConservationObjectEntity.weight, ConservationObjectEntity.measurement_unit, ConservationObjectEntity.owner_name, ConservationObjectEntity.location_description, ConservationObjectEntity.acquisition_date, ConservationObjectEntity.inventory_number, ConservationObjectEntity.description, ConservationObjectEntity.image_ids, ConservationObjectEntity.created_at, ConservationObjectEntity.updated_at, ConservationObjectEntity.sync_status FROM ConservationObjectEntity ORDER BY updated_at DESC") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getDouble(4),
      cursor.getDouble(5),
      cursor.getDouble(6),
      cursor.getDouble(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getString(10),
      cursor.getString(11),
      cursor.getLong(12),
      cursor.getString(13),
      cursor.getString(14),
      cursor.getString(15)!!,
      cursor.getLong(16)!!,
      cursor.getLong(17)!!,
      cursor.getString(18)!!
    )
  }

  public fun selectAll(): Query<ConservationObjectEntity> = selectAll { id, title, object_type,
      materials, height, width, depth, diameter, weight, measurement_unit, owner_name,
      location_description, acquisition_date, inventory_number, description, image_ids, created_at,
      updated_at, sync_status ->
    ConservationObjectEntity(
      id,
      title,
      object_type,
      materials,
      height,
      width,
      depth,
      diameter,
      weight,
      measurement_unit,
      owner_name,
      location_description,
      acquisition_date,
      inventory_number,
      description,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectById(id: String, mapper: (
    id: String,
    title: String,
    object_type: String,
    materials: String,
    height: Double?,
    width: Double?,
    depth: Double?,
    diameter: Double?,
    weight: Double?,
    measurement_unit: String?,
    owner_name: String?,
    location_description: String?,
    acquisition_date: Long?,
    inventory_number: String?,
    description: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByIdQuery(id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getDouble(4),
      cursor.getDouble(5),
      cursor.getDouble(6),
      cursor.getDouble(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getString(10),
      cursor.getString(11),
      cursor.getLong(12),
      cursor.getString(13),
      cursor.getString(14),
      cursor.getString(15)!!,
      cursor.getLong(16)!!,
      cursor.getLong(17)!!,
      cursor.getString(18)!!
    )
  }

  public fun selectById(id: String): Query<ConservationObjectEntity> = selectById(id) { id_, title,
      object_type, materials, height, width, depth, diameter, weight, measurement_unit, owner_name,
      location_description, acquisition_date, inventory_number, description, image_ids, created_at,
      updated_at, sync_status ->
    ConservationObjectEntity(
      id_,
      title,
      object_type,
      materials,
      height,
      width,
      depth,
      diameter,
      weight,
      measurement_unit,
      owner_name,
      location_description,
      acquisition_date,
      inventory_number,
      description,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> search(
    `value`: String,
    value_: String,
    value__: String,
    mapper: (
      id: String,
      title: String,
      object_type: String,
      materials: String,
      height: Double?,
      width: Double?,
      depth: Double?,
      diameter: Double?,
      weight: Double?,
      measurement_unit: String?,
      owner_name: String?,
      location_description: String?,
      acquisition_date: Long?,
      inventory_number: String?,
      description: String?,
      image_ids: String,
      created_at: Long,
      updated_at: Long,
      sync_status: String,
    ) -> T,
  ): Query<T> = SearchQuery(value, value_, value__) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getDouble(4),
      cursor.getDouble(5),
      cursor.getDouble(6),
      cursor.getDouble(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getString(10),
      cursor.getString(11),
      cursor.getLong(12),
      cursor.getString(13),
      cursor.getString(14),
      cursor.getString(15)!!,
      cursor.getLong(16)!!,
      cursor.getLong(17)!!,
      cursor.getString(18)!!
    )
  }

  public fun search(
    value_: String,
    value__: String,
    value___: String,
  ): Query<ConservationObjectEntity> = search(value_, value__, value___) { id, title, object_type,
      materials, height, width, depth, diameter, weight, measurement_unit, owner_name,
      location_description, acquisition_date, inventory_number, description, image_ids, created_at,
      updated_at, sync_status ->
    ConservationObjectEntity(
      id,
      title,
      object_type,
      materials,
      height,
      width,
      depth,
      diameter,
      weight,
      measurement_unit,
      owner_name,
      location_description,
      acquisition_date,
      inventory_number,
      description,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectPending(mapper: (
    id: String,
    title: String,
    object_type: String,
    materials: String,
    height: Double?,
    width: Double?,
    depth: Double?,
    diameter: Double?,
    weight: Double?,
    measurement_unit: String?,
    owner_name: String?,
    location_description: String?,
    acquisition_date: Long?,
    inventory_number: String?,
    description: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(-2_131_364_513, arrayOf("ConservationObjectEntity"), driver,
      "ConservationObject.sq", "selectPending",
      "SELECT ConservationObjectEntity.id, ConservationObjectEntity.title, ConservationObjectEntity.object_type, ConservationObjectEntity.materials, ConservationObjectEntity.height, ConservationObjectEntity.width, ConservationObjectEntity.depth, ConservationObjectEntity.diameter, ConservationObjectEntity.weight, ConservationObjectEntity.measurement_unit, ConservationObjectEntity.owner_name, ConservationObjectEntity.location_description, ConservationObjectEntity.acquisition_date, ConservationObjectEntity.inventory_number, ConservationObjectEntity.description, ConservationObjectEntity.image_ids, ConservationObjectEntity.created_at, ConservationObjectEntity.updated_at, ConservationObjectEntity.sync_status FROM ConservationObjectEntity WHERE sync_status = 'PENDING'") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3)!!,
      cursor.getDouble(4),
      cursor.getDouble(5),
      cursor.getDouble(6),
      cursor.getDouble(7),
      cursor.getDouble(8),
      cursor.getString(9),
      cursor.getString(10),
      cursor.getString(11),
      cursor.getLong(12),
      cursor.getString(13),
      cursor.getString(14),
      cursor.getString(15)!!,
      cursor.getLong(16)!!,
      cursor.getLong(17)!!,
      cursor.getString(18)!!
    )
  }

  public fun selectPending(): Query<ConservationObjectEntity> = selectPending { id, title,
      object_type, materials, height, width, depth, diameter, weight, measurement_unit, owner_name,
      location_description, acquisition_date, inventory_number, description, image_ids, created_at,
      updated_at, sync_status ->
    ConservationObjectEntity(
      id,
      title,
      object_type,
      materials,
      height,
      width,
      depth,
      diameter,
      weight,
      measurement_unit,
      owner_name,
      location_description,
      acquisition_date,
      inventory_number,
      description,
      image_ids,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun insertObject(
    id: String,
    title: String,
    object_type: String,
    materials: String,
    height: Double?,
    width: Double?,
    depth: Double?,
    diameter: Double?,
    weight: Double?,
    measurement_unit: String?,
    owner_name: String?,
    location_description: String?,
    acquisition_date: Long?,
    inventory_number: String?,
    description: String?,
    image_ids: String,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) {
    driver.execute(-1_561_996, """
        |INSERT OR REPLACE INTO ConservationObjectEntity(
        |    id, title, object_type, materials, height, width, depth, diameter, weight,
        |    measurement_unit, owner_name, location_description, acquisition_date,
        |    inventory_number, description, image_ids, created_at, updated_at, sync_status
        |) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """.trimMargin(), 19) {
          bindString(0, id)
          bindString(1, title)
          bindString(2, object_type)
          bindString(3, materials)
          bindDouble(4, height)
          bindDouble(5, width)
          bindDouble(6, depth)
          bindDouble(7, diameter)
          bindDouble(8, weight)
          bindString(9, measurement_unit)
          bindString(10, owner_name)
          bindString(11, location_description)
          bindLong(12, acquisition_date)
          bindString(13, inventory_number)
          bindString(14, description)
          bindString(15, image_ids)
          bindLong(16, created_at)
          bindLong(17, updated_at)
          bindString(18, sync_status)
        }
    notifyQueries(-1_561_996) { emit ->
      emit("ConservationObjectEntity")
    }
  }

  public fun deleteById(id: String) {
    driver.execute(199_173_689, """DELETE FROM ConservationObjectEntity WHERE id = ?""", 1) {
          bindString(0, id)
        }
    notifyQueries(199_173_689) { emit ->
      emit("ConditionReportEntity")
      emit("ConservationObjectEntity")
    }
  }

  private inner class SelectByIdQuery<out T : Any>(
    public val id: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ConservationObjectEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ConservationObjectEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(1_073_595_658,
        """SELECT ConservationObjectEntity.id, ConservationObjectEntity.title, ConservationObjectEntity.object_type, ConservationObjectEntity.materials, ConservationObjectEntity.height, ConservationObjectEntity.width, ConservationObjectEntity.depth, ConservationObjectEntity.diameter, ConservationObjectEntity.weight, ConservationObjectEntity.measurement_unit, ConservationObjectEntity.owner_name, ConservationObjectEntity.location_description, ConservationObjectEntity.acquisition_date, ConservationObjectEntity.inventory_number, ConservationObjectEntity.description, ConservationObjectEntity.image_ids, ConservationObjectEntity.created_at, ConservationObjectEntity.updated_at, ConservationObjectEntity.sync_status FROM ConservationObjectEntity WHERE id = ?""",
        mapper, 1) {
      bindString(0, id)
    }

    override fun toString(): String = "ConservationObject.sq:selectById"
  }

  private inner class SearchQuery<out T : Any>(
    public val `value`: String,
    public val value_: String,
    public val value__: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ConservationObjectEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ConservationObjectEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(344_945_092, """
    |SELECT ConservationObjectEntity.id, ConservationObjectEntity.title, ConservationObjectEntity.object_type, ConservationObjectEntity.materials, ConservationObjectEntity.height, ConservationObjectEntity.width, ConservationObjectEntity.depth, ConservationObjectEntity.diameter, ConservationObjectEntity.weight, ConservationObjectEntity.measurement_unit, ConservationObjectEntity.owner_name, ConservationObjectEntity.location_description, ConservationObjectEntity.acquisition_date, ConservationObjectEntity.inventory_number, ConservationObjectEntity.description, ConservationObjectEntity.image_ids, ConservationObjectEntity.created_at, ConservationObjectEntity.updated_at, ConservationObjectEntity.sync_status FROM ConservationObjectEntity
    |WHERE title LIKE '%' || ? || '%'
    |   OR description LIKE '%' || ? || '%'
    |   OR inventory_number LIKE '%' || ? || '%'
    |ORDER BY updated_at DESC
    """.trimMargin(), mapper, 3) {
      bindString(0, value)
      bindString(1, value_)
      bindString(2, value__)
    }

    override fun toString(): String = "ConservationObject.sq:search"
  }
}
