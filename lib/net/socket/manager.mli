(*
 * Copyright (c) 2011 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

exception Error of string
module Unix :
  sig
    type ipv4 = int32
    type port = int
    type uid = int
    type 'a fd
    type 'a resp = OK of 'a | Err of string | Retry
    external tcpv4_connect : ipv4 -> port -> [ `tcpv4 ] fd resp = "caml_tcpv4_connect"
    external tcpv4_bind : ipv4 -> port -> [ `tcpv4 ] fd resp = "caml_tcpv4_bind"
    external tcpv4_listen : [ `tcpv4 ] fd -> unit resp = "caml_socket_listen"
    external tcpv4_accept : [ `tcpv4 ] fd -> ([ `tcpv4 ] fd * ipv4 * port) resp = "caml_tcpv4_accept"
    external udpv4_socket : unit -> [ `udpv4 ] fd = "caml_udpv4_socket"
    external udpv4_bind : ipv4 -> port -> [ `udpv4 ] fd resp = "caml_udpv4_bind"
    external udpv4_recvfrom : [ `udpv4 ] fd -> string -> int -> int -> (ipv4 * port * int) resp = "caml_udpv4_recvfrom"
    external udpv4_sendto : [ `udpv4 ] fd -> string -> int -> int -> ipv4 * port -> int resp = "caml_udpv4_sendto"
    external domain_uid : unit -> uid = "caml_domain_name"
    external domain_bind : uid -> [ `domain ] fd resp = "caml_domain_bind"
    external domain_connect : uid -> [ `domain ] fd resp = "caml_domain_connect"
    external domain_accept : [ `domain ] fd -> [ `domain ] fd resp = "caml_domain_accept"
    external domain_list : unit -> uid list = "caml_domain_list"
    external domain_read : [ `domain ] fd -> string resp = "caml_domain_read"
    external domain_write : [ `domain ] fd -> string -> unit resp = "caml_domain_write"
    external domain_send_pipe : [ `domain ] fd -> [< `rd_pipe | `wr_pipe ] fd -> unit resp = "caml_domain_send_fd"
    external domain_recv_pipe : [ `domain ] fd -> [< `rd_pipe | `wr_pipe ] fd resp = "caml_domain_recv_fd"
    external pipe : unit -> ([ `rd_pipe ] fd * [ `wr_pipe ] fd) resp = "caml_alloc_pipe"
    external connect_result : [< `domain | `tcpv4 ] fd -> unit resp = "caml_socket_connect_result"
    external read : [< `rd_pipe | `tcpv4 | `udpv4 ] fd -> string -> int -> int -> int resp = "caml_socket_read"
    external write : [< `tcpv4 | `udpv4 | `wr_pipe ] fd -> string -> int -> int -> int resp = "caml_socket_write"
    external close : [< `domain | `rd_pipe | `tcpv4 | `udpv4 | `wr_pipe ] fd -> unit = "caml_socket_close"
    external fd_to_int : 'a fd -> int = "%identity"
    val fdbind : (int -> 'a Lwt.t) -> ('b fd -> 'c resp) -> 'b fd -> 'c Lwt.t
    val iobind : ('a -> 'b resp) -> 'a -> 'b Lwt.t
  end

type t
type interface
type id
val create : (t -> interface -> id -> unit Lwt.t) -> unit Lwt.t
val local_peers : 'a -> Unix.uid list
val local_uid : 'a -> Unix.uid
val connect_to_peer : t -> Nettypes.peer_uid -> [ `domain ] Unix.fd option Lwt.t
val listen_to_peers : t -> (int -> [< `rd_pipe | `wr_pipe ] Unix.fd * [< `rd_pipe | `wr_pipe ] Unix.fd -> unit Lwt.t) -> unit Lwt.t
val connect : t -> Nettypes.peer_uid -> ([ `rd_pipe ] Unix.fd * [ `wr_pipe ] Unix.fd -> 'a Lwt.t) -> 'a Lwt.t
val get_udpv4 : t -> [ `udpv4 ] Unix.fd
val register_udpv4_listener : t -> Nettypes.ipv4_addr option * int -> [ `udpv4 ] Unix.fd -> unit
val get_udpv4_listener : t -> Nettypes.ipv4_addr option * Unix.port -> [ `udpv4 ] Unix.fd Lwt.t
