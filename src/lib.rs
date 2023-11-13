use std::process::Command;

pub fn run_caesar_cipher(data: &str, shifter: i32) -> String {
    let mut command = Command::new("target/caesar_cipher");

    let command = command
        .arg(format!("'{}'", data))
        .arg(format!("{}", shifter.to_string()));

    let output = match command.output() {
        Ok(v) => v.stdout,
        Err(_) => Vec::new(),
    };

     match String::from_utf8(output) {
        Ok(v) => {
            let cleaned = &v.trim()[1..v.len()-2];
            cleaned.to_string()
        },
        Err(_) => "".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_uppercase_a_shift_1(){
        let cipher_result = run_caesar_cipher("A", 1);
        let got = cipher_result.trim();

        let expected = "B".to_string();
        assert_eq!(got, expected);
    }

    #[test]
    fn test_hello_world_shift_5() {
        let cipher_result = run_caesar_cipher("Hello, World!", 5);
        let got = cipher_result.trim();

        let expected = "Mjqqt, Btwqi!".to_string();
        assert_eq!(got, expected);
    }
}
