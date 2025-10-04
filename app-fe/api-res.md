## Login

- Body
{
  "username":"user1",
  "password":"123"
}

- Response
{
    "token": "***"
}

## Get me

- Auth: BearerToken

- Response 
{
  "id": 3,
  "username": "user1",
  "password": "123",
  "email": "user@gmail.com",
  "fullName": "User One",
  "phone": "0987654321",
  "balance": 50000,
  "role": "USER"
}

## Create Tuition

- Body
{
  "semester": "22025",
  "majorCode": "CNTT",
  "amount": 1000
}

- Response
{
  "semester": "22025",
  "majorCode": "CNTT",
  "tuitions": [
    {
      "tuitionCode": "22025sv1",
      "studentCode": "sv1",
      "name": "Nguyễn Văn A",
      "major": "CNTT",
      "amount": 1000,
      "status": "Chưa thanh toán"
    },
    {
      "tuitionCode": "22025sv2",
      "studentCode": "sv2",
      "name": "Trần Thị B",
      "major": "CNTT",
      "amount": 1000,
      "status": "Chưa thanh toán"
    }
  ]
}

## Xac thuc OTP

- Body
{
  "otpCode": "319155"
}