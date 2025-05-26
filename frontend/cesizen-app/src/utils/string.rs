pub trait StringPreview {
    fn preview(&self, length: usize) -> String;
}

impl StringPreview for str {
    fn preview(&self, length: usize) -> String {
        if self.len() <= length {
            self.to_string()
        } else {
            format!("{}...", self.chars().take(length).collect::<String>())
        }
    }
}
