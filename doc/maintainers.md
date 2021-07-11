# Maintainers

The document shows which people maintain, own, or simply are interested in
reviews of patches for Taranotool subsystems.

**Maintainers** are the people who can approve the changes for the given
subsystems if they are not trivial. Not always you need an approval from all of
them. But better get it. The maintainers can interfere on any stage of a patch
development to request changes if they are justified. That might even lead to
the patch being entirely discarded. Approvals can save time and protect from
disappointment due to wasted time.

**Reviewers** can help with patches review because they are supposed to be
familiar with the code and can spot bugs, code style violations, give technical
advices, participate in discussions. They also should be attentive to notice if
a patch starts deviating from its initial design and needs re-approvals from the
maintainers. Try to balance over the reviewers if there are many of them,
depending on their load with other work. If reviewers are not specified, use
the maintainers to ask who you should talk to or send your patch to.

You definitely need maintainers approval when you
- Change user visible behaviour;
- Touch backward compatibility;
- Do a big patch which notably changes a subsystem's architecture / design /
  internal API. For such changes it is best if you come up with a proposal in
  text / speech format which you can pitch to the maintainers before you start
  coding.

**The rule of thumb**: get approvals from all maintainers and from at least 2
reviewers to get a patch merged. Reviewers can be the same as maintainers
sometimes.

When you make a patch or a design and don't know who to send it to or talk about
it with whom, use the people listed beside the component you changed. If you
can't find a component, look up the closest component you can in the list.

People and subsystem names are listed in alphabetical order, keep them sorted
when change.

---
## tarantool
The entire Tarantool DBMS and the application server. Maintainers listed here
are default entry points when can't find anything better below.

*Maintainers*: Alexander Turenko, Dmitry Oboukhov, Igor Munkin, Kirill Yukhin,
Mons Anderson, Sergey Ostanevich, Vladislav Shpilevoy.

---
## box
The core system where nearly everything is stored and accessed with its own API.
Rarely a change affects the entire box. Usually all patches land into
independent parts of box.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Sergey Petrenko, Vladislav Shpilevoy.

---
## box / call
Functions in `box.func` and `box.lib`, `IPROTO_CALL`/`IPROTO_EVAL` requests.
How to store, load, unload, and execute the stored and dynamic functions in all
the available languages and protocols.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## box / cfg
Configuration via `box.cfg`, environment variables. Only implementation of it
not depending on other subsystems and option meanings.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Sergey Petrenko,
Vladislav Shpilevoy.

---
## box / engine
Engine-agnostic code used by all the engine implementations, common functions
and options.

*Maintainers*: Alexander Lyapunov, Nikita Pettik.

*Reviewers*: Alexander Lyapunov, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / engine / blackhole
Stores data in xlog files.

*Maintainers*: Alexander Lyapunov, Vladimir Davydov.

---
## box / engine / memtx
Storage, index types, engine-specific transaction manager.

*Maintainers*: Alexander Lyapunov, Nikita Pettik.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov.

---
## box / engine / service
Data is virtualized. Used to represent something as a space with tuples. For
instance, session settings.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Vladislav Shpilevoy, Mergen Imeev.

---
## box / engine / sysview
Filter over other system spaces based on access rights.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Vladimir Davydov.

---
## box / engine / vinyl
Storage, LSM index, engine-specific transaction manager, vylog.

*Maintainers*: Alexander Lyapunov, Vladimir Davydov.

*Reviewers*: Alexander Lyapunov, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / gc
Garbage collector for snapshots and xlog files, its consumers.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / info
Box info collection and display. Includes `box.info`.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Sergey Petrenko,
Vladimir Davydov, Vladislav Shpilevoy.

---
## box / iproto
Network threads, the binary protocol, interaction with the TX thread, private
API, configuration options.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / journal
Journal interface. Agnostic of the storage layer - WAL, no WAL, whether fsync is
used.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## box / key def
Key def, both internal and private API, in all languages.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Lyapunov, Alexander Turenko, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## box / merger
Sorting merger for tuples, tables, and arrays coming from different sources.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko, Vladislav Shpilevoy.

---
## box / recovery
Read and replay of snapshots and xlog files. Force recovery.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## box / replication
The entire replication subsystem.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / replication / applier
Applier is responsible for downloading transactions from a remote peer.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / replication / election
Leader election subsystem. Wraps Raft library with storage specific details.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## box / replication / relay
Relay is responsible for sending transactions to a remote peer.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / replication / synchro
Synchronous replication. Is inside all the replication subsystems but most of it
is in the transaction limbo module.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## box / schema
Spaces, indexes, sequences, constraints, stored functions, access to them,
users. Agnostic of engine and index types.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / schema / constraint
Checks, foreign keys, nullable as a constraint, index being unique as a
constraint, and more. What is and what is not a constraint, whether need to
add a new constraint type or drop an old one, where to store them, when and how
to validate them.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik,
Vladislav Shpilevoy.

---
## box / schema / func
Stored functions in `_func`, `_vfunc`, their options, privileges, languages.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik,
Vladislav Shpilevoy.

---
## box / schema / index
Index code agnostic of engines and index types. Ephemeral indexes; the ones
stored in `_index`, `_vindex`.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / schema / space
Space code agnostic of engines and index types. Ephemeral spaces; the ones
stored in `_space`, `_vspace`.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / schema / sequence
Sequences, their storage in `_sequence`, `_sequence_data`, `_space_sequence`,
`_vsequence`, their API in all languages.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / schema / user
Users, their access rights checking, referencing in storage objects, API in all
languages, storage in `_user`, `_vuser`, `_priv`, `_vpriv`.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Mergen Imeev, Nikita Pettik, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / session
Session owns a fiber, stores its user and access rights. In case of remote
connections exists not bound to one fiber. Has settings, private and public
API.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Mergen Imeev, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / shutdown
Instance graceful shutdown subsystem, its triggers, options, ways of user
notification, protocol.

*Maintainers*: Alexander Lyapunov, Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## box / snapshot
Instance snapshot subsystem. Its creation, write to disk, format, content.

*Maintainers*: Alexander Lyapunov, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / sql
SQL syntax, parser, virtual machine, statistics, planing, optimizations, and
more.

*Maintainers*: Kirill Yukhin, Mergen Imeev, Vladislav Shpilevoy.

*Reviewers*: Igor Munkin, Mergen Imeev, Nikita Pettik, Timur Safin,
Vladislav Shpilevoy.

---
## box / stat
Instance statistics: RPS, latency, memory, all info from `box.stat`.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / tuple
Tuple is the basic storage unit for all the data. Its code is spread all over
the entire code base, and has lots of submodules such as JSON updates, field
access in Lua, tuple format, comparators, and much more.

*Maintainers*: Alexander Lyapunov, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / tuple / compare
Tuple comparators and their templates, tuple hints, hashes.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / tuple / format
Format describes spaces and tuples.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / tuple / update
Tuple updates, upserts, transformation, slicing.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / txn
Engine-agnostic transaction code.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik, Mergen Imeev,
Nikita Pettik, Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / upgrade
Instance upgrade. New schema appliance, life with an old schema on a new
instance.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik, Mergen Imeev,
Nikita Pettik, Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## box / wal
Write Ahead Log. Writing to disk, watcher notifications, options such as fsync
and "no WAL" mode.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / xlog
Xlog encoding, reading, writing, zipping.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## box / xrow
Xrow requests, responses, their fields and codecs, versions.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## clock
Clock functions to get wall, monotonic, process times and more. In all
languages.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Vladislav Shpilevoy.

---
## collation
Collation code and its API in all languages. The basic collation library,
box-specific collations with access rights.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Mergen Imeev, Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## csv
CSV parser, in all languages.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko.

---
## decimal
Decimal and all its usages and API, the basic library, its representation and
behaviour in all languages, codecs.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Igor Munkin, Sergey Petrenko, Vladislav Shpilevoy.

---
## error
Errors, diags, their codes and types, exceptions, messages, reference counting,
globals.

*Maintainers*: Alexander Turenko, Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Mergen Imeev, Nikita Pettik,
Vladislav Shpilevoy.

---
## feedback daemon
Instance statistics and state reporting to a remote server.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Sergey Petrenko, Vladislav Shpilevoy.

---
## httpc
HTTP client.

*Maintainers*: Alexander Turenko, Mons Anderson.

*Reviewers*: Alexander Turenko.

---
## ibuf
IBuf module, includes the basic implementation in small/ library, API via box
functions and in all languages.

*Maintainers*: Alexander Turenko, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Alexander Turenko, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib
All libraries in general and the ones not extracted into their own subsystem.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Vladislav Shpilevoy.

---
## lib / assoc
Sugar on top of hash tables with frequently used key/value types.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / backtrace
Backtrace collection, resolution, walking.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / base64
Base64 codecs.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Sergey Nikiforov,
Vladislav Shpilevoy.

---
## lib / bit
Bit manipulations, iteration, counting.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik, Igor Munkin,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / bitset
Bitset data structure.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / bloom
Bloom filter.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik, Igor Munkin,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / bps tree
B+* tree library.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik, Igor Munkin,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / c-ares
Async domain name resolution.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov.

---
## lib / cbus
Inter-thread communication.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / coio
Async tasks with worker thread pool.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / cord_buf
Shared buffer with automatic deletion.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Igor Munkin, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / coro
Coroutine implementation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / cpu feature
CPU attributes checking.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Igor Munkin, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / crash
Crash handling.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / crc32
CRC32 hash.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / curl
Curl link, build, wrap.

*Maintainers*: Alexander Turenko, Mons Anderson.

*Reviewers*: Alexander Turenko.

---
## lib / libeio
Asynchronous IO functions for C.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / libev
Event loop library.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / libutil

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / evio
Functions to work with sockets in libev.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Evgeny Mekhanik, Sergey Petrenko,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / fakesys
Fake system resources and API, such as file descriptors, network. For testing.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / fiber
Threading library with coroutine support. Fiber channel, latch, condition, pool
and all the other structures on top of the fibers. Built on top of libcoro.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Igor Munkin, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / fifo
FIFO data structure.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik.

---
## lib / fio
Wraps standard file IO functions.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / guava
Guava hash.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Vladislav Shpilevoy.

---
## lib / heap
Heap data structure.

*Maintainers*: Vladimir Davydov, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / histogram
Histogram calculator.

*Maintainers*: Vladimir Davydov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / http parser

*Maintainers*: Alexander Turenko, Mons Anderson.

*Reviewers*: Alexander Turenko, Vladislav Shpilevoy.

---
## lib / info
Language agnostic API for info collection. Allows not to depend on Lua anywhere
but still fetch data for `box.info`.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / json
JSON path parser, JSON path tree.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / latency
Latency calculator.

*Maintainers*: Vladimir Davydov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / light
Hash table.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik.

---
## lib / lsregion
Sequential allocator with efficient FIFO deallocation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / matras
Memory allocator with read view support.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik.

---
## lib / memory
Global memory initialization and destruction.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik.

---
## lib / mempool
Fixed size blocks allocator.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / mhash
Hash table.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / mpstream
MessagePack encoding stream not depending on an allocator.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Mergen Imeev, Nikita Pettik, Sergey Petrenko,
Vladislav Shpilevoy.

---
## lib / obuf
Dynamic memory buffer with multiple blocks inside to reduce reallocs.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / path lock
File and directory locking.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / pmurhash
MurmurHash3 implementation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / queue
Singly-linked intrusive list in C macros.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / raft
Raft's leader election.

*Maintainers*: Sergey Petrenko, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / random
Random bytes and numbers generation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / ratelimit
Event count per time duration limit.

*Maintainers*: Vladimir Davydov.

*Reviewers*: Cyrill Gorcunov, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / reflection
Struct and class meta information available at runtime. Their types, methods.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / region
Memory allocator consisting of list of blocks, has very efficient deallocation.

*Maintainers*: Alexander Lyapunov, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / rmean
Rolling average.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / rope
Rope data structure. Sorted storage for value ranges with efficient split and
merge of nodes.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Sergey Petrenko, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / rtree
R-tree data structure.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik.

---
## lib / say
Logging.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / scoped guard
C++ class to invoke code when leave the current scope.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladislav Shpilevoy.

---
## lib / scramble
Password encoding and checking.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / sha1
SHA-1 hash implementation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / sio
Wrappers for socket standard functions with tarantool error objects instead of
errnos.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / slab arena
Storage and allocator of large memory blocks for multiple threads.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / slab cache
Thread-local cache of slabs returned from the slab arena.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / small
Memory allocator consisting of multiple mempools with fixed size blocks.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Evgeny Mekhanik, Nikita Pettik,
Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / sptree
Unknown type of tree.

*Maintainers*: Alexander Lyapunov.

*Reviewers*: Alexander Lyapunov, Vladislav Shpilevoy.

---
## lib / ssl
SSL certificates, their discovery.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko.

---
## lib / stailq
Singly-linked intrusive list data structure.

*Maintainers*: Alexander Lyapunov, Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / static
Cyclic memory allocator based on a global thread-local block of constant size.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / systemd
Interaction with systemd.

*Maintainers*: Alexander Turenko, Mons Anderson.

*Reviewers*: Alexander Turenko.

---
## lib / trigger
Triggers storage, invocation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lib / tt_pthread
Wrappers around pthread functions.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Lyapunov, Cyrill Gorcunov, Evgeny Mekhanik,
Nikita Pettik, Vladimir Davydov, Vladislav Shpilevoy.

---
## lib / vclock
Vector logical clock.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / version
Version information from the executable, version manipulations, checking,
codecs.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / xxhash
Fast hash algorithm.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Vladislav Shpilevoy.

---
## lib / xstream
Stream to feed a sequence of xrows agnostic of the consumer details.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lib / zstd
Data compression.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## lua
The entire Lua world.

*Maintainers*: Igor Munkin, Mons Anderson, Sergey Ostanevich.

*Reviewers*: Igor Munkin, Sergey Kaplun, Sergey Ostanevich.

---
## lua / argparse
Command line arguments parser.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / buffer
IBuf's representation in Lua, global auto-freeing buffers, private functions and
objects like FFI stash used only by tarantool itself.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / json
Lua JSON codecs, based on lua-cjson library.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / console

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / crypto
Encryption and decryption algorithms.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / debug
Wrapper around the built-in debug module with new functions.

*Maintainers*: Igor Munkin.

*Reviewers*: Igor Munkin.

---
## lua / digest
Hash algorithms.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / env
Environment variables.

*Maintainers*: Igor Munkin, Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Igor Munkin, Vladislav Shpilevoy.

---
## lua / errno
Global errno code access and change.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Igor Munkin, Vladislav Shpilevoy.

---
## lua / fiber
Fibers representation in Lua.

*Maintainers*: Igor Munkin, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin, Sergey Petrenko,
Vladislav Shpilevoy.

---
## lua / fio
File IO operations not blocking the thread.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / help
Help collection and display.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / iconv
Iconv standard functions in Lua.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / log
Logging in Lua via say module.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / luafun
Lua functional programming library.

*Maintainers*: Igor Munkin.

*Reviewers*: Igor Munkin, Vladislav Shpilevoy.

---
## lua / luajit
All the Lua builtin modules, Lua as a language, runtime, VM and JIT.

*Maintainers*: Igor Munkin, Sergey Ostanevich.

*Reviewers*: Igor Munkin, Sergey Kaplun, Sergey Ostanevich.

---
## lua / luarocks
Luarocks packet manager.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / msgpackffi
MessagePack encoding in Lua and ffi without Lua C API access.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / netbox
Tarantool connector.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Evgeny Mekhanik, Igor Munkin, Vladimir Davydov,
Vladislav Shpilevoy.

---
## lua / pwd
System users access.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / socket
Socket functions not blocking the thread.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## lua / strict
Checking of undeclared global variables.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / string
Extension of the built-in string functions.

*Maintainers*: Igor Munkin.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / table
Extension of the built-in table functions.

*Maintainers*: Igor Munkin.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / tap
TAP testing framework.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## lua / utf8
Function to work with unicode.

*Maintainers*: Mons Anderson, Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## msgpack
MessagePack codecs in Lua C.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.

---
## pickle
Lua types encoding as binary data.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Vladislav Shpilevoy.

---
## popen
Popen not blocking the thread.

*Maintainers*: Alexander Turenko.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin,
Vladislav Shpilevoy.

---
## port
Port carries any kind of data. Allows to connect different subsystems as a
communication unit not exposing their details to each other.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Mergen Imeev, Nikita Pettik,
Sergey Petrenko, Vladislav Shpilevoy.

---
## swim
SWIM protocol implementation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Cyrill Gorcunov, Sergey Petrenko, Vladislav Shpilevoy.

---
## title
Process title access and manipulation.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Vladislav Shpilevoy.

---
## uri
URI parser.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Evgeny Mekhanik,
Vladislav Shpilevoy.

---
## uuid
UUID creation, comparison, manipulation, codecs.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Cyrill Gorcunov, Igor Munkin, Mergen Imeev,
Nikita Pettik, Sergey Petrenko, Timur Safin, Vladislav Shpilevoy.

---
## yaml
YAML codecs, the basic library and Lua API.

*Maintainers*: Vladislav Shpilevoy.

*Reviewers*: Alexander Turenko, Igor Munkin, Vladislav Shpilevoy.
