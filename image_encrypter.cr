require "openssl/cipher"

superman = File.read("superman.bmp").to_slice

headers = superman[0, 54]
data = superman[54, superman.size - 54]

def simple_enc(data : Bytes, secret : Bytes) : Bytes
  data.map_with_index{|b, i| b ^ secret[i%secret.size]}
end

def encrypt(value : Bytes, alg = "aes-256-cbc", secret = "much_password") : Bytes
  cipher = OpenSSL::Cipher.new(alg)
  cipher.encrypt
  cipher.key = secret + (0..32-secret.size).join("")
  iv = cipher.random_iv

  encrypted_data = IO::Memory.new
  encrypted_data.write(cipher.update(value))
  encrypted_data.write(cipher.final)
  encrypted_data.to_slice
end

File.open("superman_simple.bmp", "w") do |f|
  f.write headers
  f.write simple_enc(data, "much password so secret".to_slice)
end

File.open("superman_ecb.bmp", "w") do |f|
  f.write headers
  f.write encrypt(data, "aes-256-ecb", "much password so secret")
end

File.open("superman_ctr.bmp", "w") do |f|
  f.write headers
  f.write encrypt(data, "aes-256-ctr", "much password so secret")
end
