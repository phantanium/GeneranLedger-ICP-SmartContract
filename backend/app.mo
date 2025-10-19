import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Int "mo:base/Int";

// TAMBAHKAN 'persistent' di sini!
persistent actor BukuKas {
  public type TipeTransaksi = {
    #Pemasukan;
    #Pengeluaran;
  };

  public type Transaksi = {
    id: Nat;
    deskripsi: Text;
    jumlah: Nat;
    tipe: TipeTransaksi;
    waktu: Time.Time;
  };

  stable var idSelanjutnya: Nat = 1;
  stable var transaksiStabil: [Transaksi] = [];
  
  transient var semuaTransaksi: Buffer.Buffer<Transaksi> = Buffer.fromArray(transaksiStabil);

  system func preupgrade() {
    transaksiStabil := Buffer.toArray(semuaTransaksi);
  };

  system func postupgrade() {
    semuaTransaksi := Buffer.fromArray(transaksiStabil);
  };

  public func catatTransaksi(deskripsi: Text, jumlah: Nat, tipe: TipeTransaksi) : async Transaksi {
    let transaksiBaru: Transaksi = {
      id = idSelanjutnya;
      deskripsi = deskripsi;
      jumlah = jumlah;
      tipe = tipe;
      waktu = Time.now();
    };

    semuaTransaksi.add(transaksiBaru);
    idSelanjutnya += 1;

    return transaksiBaru;
  };

  public query func lihatSemuaTransaksi() : async [Transaksi] {
    return Buffer.toArray(semuaTransaksi);
  };

  public query func hitungSaldo() : async Int {
    var saldo: Int = 0;

    for (transaksi in semuaTransaksi.vals()) {
      switch (transaksi.tipe) {
        case (#Pemasukan) {
          saldo += transaksi.jumlah;
        };
        case (#Pengeluaran) {
          saldo -= transaksi.jumlah;
        };
      };
    };

    return saldo;
  };
}