resource "aws_key_pair" "my_kp" {
  key_name   = "my-kp"
  public_key = file("~/.ssh/my_key_pair.pub")
}
