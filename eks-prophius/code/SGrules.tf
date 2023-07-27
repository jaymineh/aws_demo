variable "inEKSmain" {
  type = list(number)
  default = [10250,6443,443,2379,2380]
}

variable "outEKSmain" {
    type = list(number)
    default = [10250,6443,443,2379,2380]
}

variable "inEKSworker" {
  type = list(number)
  default = [10250,6443,443,2379,2380]
}

variable "outEKSworker" {
    type = list(number)
    default = [10250,6443,443,2379,2380]
}

variable "inECR" {
  type = list(number)
  default = [80,443]
}

variable "outECR" {
    type = list(number)
    default = [80,443]
}

variable "inSQL" {
  type = list(number)
  default = [3306,22]
}

variable "outSQL" {
    type = list(number)
    default = [80,443,22,3306]
}