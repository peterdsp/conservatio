package com.conservatio.db

import app.cash.sqldelight.Query
import app.cash.sqldelight.TransacterImpl
import app.cash.sqldelight.db.QueryResult
import app.cash.sqldelight.db.SqlCursor
import app.cash.sqldelight.db.SqlDriver
import kotlin.Any
import kotlin.Long
import kotlin.String

public class ClientQueries(
  driver: SqlDriver,
) : TransacterImpl(driver) {
  public fun <T : Any> selectAll(mapper: (
    id: String,
    name: String,
    type: String,
    contact_person: String?,
    email: String?,
    phone: String?,
    address: String?,
    notes: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(-392_670_726, arrayOf("ClientEntity"), driver, "Client.sq", "selectAll",
      "SELECT ClientEntity.id, ClientEntity.name, ClientEntity.type, ClientEntity.contact_person, ClientEntity.email, ClientEntity.phone, ClientEntity.address, ClientEntity.notes, ClientEntity.created_at, ClientEntity.updated_at, ClientEntity.sync_status FROM ClientEntity ORDER BY name ASC") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3),
      cursor.getString(4),
      cursor.getString(5),
      cursor.getString(6),
      cursor.getString(7),
      cursor.getLong(8)!!,
      cursor.getLong(9)!!,
      cursor.getString(10)!!
    )
  }

  public fun selectAll(): Query<ClientEntity> = selectAll { id, name, type, contact_person, email,
      phone, address, notes, created_at, updated_at, sync_status ->
    ClientEntity(
      id,
      name,
      type,
      contact_person,
      email,
      phone,
      address,
      notes,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectById(id: String, mapper: (
    id: String,
    name: String,
    type: String,
    contact_person: String?,
    email: String?,
    phone: String?,
    address: String?,
    notes: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = SelectByIdQuery(id) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3),
      cursor.getString(4),
      cursor.getString(5),
      cursor.getString(6),
      cursor.getString(7),
      cursor.getLong(8)!!,
      cursor.getLong(9)!!,
      cursor.getString(10)!!
    )
  }

  public fun selectById(id: String): Query<ClientEntity> = selectById(id) { id_, name, type,
      contact_person, email, phone, address, notes, created_at, updated_at, sync_status ->
    ClientEntity(
      id_,
      name,
      type,
      contact_person,
      email,
      phone,
      address,
      notes,
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
      name: String,
      type: String,
      contact_person: String?,
      email: String?,
      phone: String?,
      address: String?,
      notes: String?,
      created_at: Long,
      updated_at: Long,
      sync_status: String,
    ) -> T,
  ): Query<T> = SearchQuery(value, value_, value__) { cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3),
      cursor.getString(4),
      cursor.getString(5),
      cursor.getString(6),
      cursor.getString(7),
      cursor.getLong(8)!!,
      cursor.getLong(9)!!,
      cursor.getString(10)!!
    )
  }

  public fun search(
    value_: String,
    value__: String,
    value___: String,
  ): Query<ClientEntity> = search(value_, value__, value___) { id, name, type, contact_person,
      email, phone, address, notes, created_at, updated_at, sync_status ->
    ClientEntity(
      id,
      name,
      type,
      contact_person,
      email,
      phone,
      address,
      notes,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun <T : Any> selectPending(mapper: (
    id: String,
    name: String,
    type: String,
    contact_person: String?,
    email: String?,
    phone: String?,
    address: String?,
    notes: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) -> T): Query<T> = Query(1_839_304_048, arrayOf("ClientEntity"), driver, "Client.sq",
      "selectPending",
      "SELECT ClientEntity.id, ClientEntity.name, ClientEntity.type, ClientEntity.contact_person, ClientEntity.email, ClientEntity.phone, ClientEntity.address, ClientEntity.notes, ClientEntity.created_at, ClientEntity.updated_at, ClientEntity.sync_status FROM ClientEntity WHERE sync_status = 'PENDING'") {
      cursor ->
    mapper(
      cursor.getString(0)!!,
      cursor.getString(1)!!,
      cursor.getString(2)!!,
      cursor.getString(3),
      cursor.getString(4),
      cursor.getString(5),
      cursor.getString(6),
      cursor.getString(7),
      cursor.getLong(8)!!,
      cursor.getLong(9)!!,
      cursor.getString(10)!!
    )
  }

  public fun selectPending(): Query<ClientEntity> = selectPending { id, name, type, contact_person,
      email, phone, address, notes, created_at, updated_at, sync_status ->
    ClientEntity(
      id,
      name,
      type,
      contact_person,
      email,
      phone,
      address,
      notes,
      created_at,
      updated_at,
      sync_status
    )
  }

  public fun insertClient(
    id: String,
    name: String,
    type: String,
    contact_person: String?,
    email: String?,
    phone: String?,
    address: String?,
    notes: String?,
    created_at: Long,
    updated_at: Long,
    sync_status: String,
  ) {
    driver.execute(207_822_031, """
        |INSERT OR REPLACE INTO ClientEntity(
        |    id, name, type, contact_person, email, phone, address, notes,
        |    created_at, updated_at, sync_status
        |) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """.trimMargin(), 11) {
          bindString(0, id)
          bindString(1, name)
          bindString(2, type)
          bindString(3, contact_person)
          bindString(4, email)
          bindString(5, phone)
          bindString(6, address)
          bindString(7, notes)
          bindLong(8, created_at)
          bindLong(9, updated_at)
          bindString(10, sync_status)
        }
    notifyQueries(207_822_031) { emit ->
      emit("ClientEntity")
    }
  }

  public fun deleteById(id: String) {
    driver.execute(-162_271_288, """DELETE FROM ClientEntity WHERE id = ?""", 1) {
          bindString(0, id)
        }
    notifyQueries(-162_271_288) { emit ->
      emit("ClientEntity")
    }
  }

  private inner class SelectByIdQuery<out T : Any>(
    public val id: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ClientEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ClientEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(712_150_681,
        """SELECT ClientEntity.id, ClientEntity.name, ClientEntity.type, ClientEntity.contact_person, ClientEntity.email, ClientEntity.phone, ClientEntity.address, ClientEntity.notes, ClientEntity.created_at, ClientEntity.updated_at, ClientEntity.sync_status FROM ClientEntity WHERE id = ?""",
        mapper, 1) {
      bindString(0, id)
    }

    override fun toString(): String = "Client.sq:selectById"
  }

  private inner class SearchQuery<out T : Any>(
    public val `value`: String,
    public val value_: String,
    public val value__: String,
    mapper: (SqlCursor) -> T,
  ) : Query<T>(mapper) {
    override fun addListener(listener: Query.Listener) {
      driver.addListener("ClientEntity", listener = listener)
    }

    override fun removeListener(listener: Query.Listener) {
      driver.removeListener("ClientEntity", listener = listener)
    }

    override fun <R> execute(mapper: (SqlCursor) -> QueryResult<R>): QueryResult<R> =
        driver.executeQuery(-783_459_629, """
    |SELECT ClientEntity.id, ClientEntity.name, ClientEntity.type, ClientEntity.contact_person, ClientEntity.email, ClientEntity.phone, ClientEntity.address, ClientEntity.notes, ClientEntity.created_at, ClientEntity.updated_at, ClientEntity.sync_status FROM ClientEntity
    |WHERE name LIKE '%' || ? || '%'
    |   OR contact_person LIKE '%' || ? || '%'
    |   OR email LIKE '%' || ? || '%'
    |ORDER BY name ASC
    """.trimMargin(), mapper, 3) {
      bindString(0, value)
      bindString(1, value_)
      bindString(2, value__)
    }

    override fun toString(): String = "Client.sq:search"
  }
}
