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
            let cleaned = &v.trim()[1..v.len() - 2];
            cleaned.to_string()
        }
        Err(_) => "".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_uppercase_a_shift_1() {
        let got = run_caesar_cipher("A", 1);
        let want = "B".to_string();
        assert_eq!(got, want);
    }

    #[test]
    fn test_hello_world_shift_5() {
        let got = run_caesar_cipher("Hello, World!", 5);
        let want = "Mjqqt, Btwqi!".to_string();
        assert_eq!(got, want);
    }

    #[test]
    fn test_uppercase_z_shift_1() {
        let got = run_caesar_cipher("Z", 1);
        let want = "A".to_string();
        assert_eq!(got, want);
    }

    #[test]
    fn test_hello_world_shift_75() {
        let got = run_caesar_cipher("Hello, World!", 75);
        let want = "Ebiil, Tloia!".to_string();
        assert_eq!(got, want);
    }

    #[test]
    fn test_hello_world_shift_negative_29(){
        let got = run_caesar_cipher("Hello, World!", -29);
        let want = "Ebiil, Tloia!".to_string();
        assert_eq!(got, want)
    }
}
