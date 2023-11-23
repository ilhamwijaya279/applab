$(document).ready(function() {
    // Add animation on form submission
    $('#submitBtn').click(function() {
        var message = $('#message').val();

        // Using AJAX to submit the form asynchronously
        $.ajax({
            type: 'POST',
            url: '/send',
            data: { message: message },
            success: function(response) {
                // Show the alert upon successful submission
                alert('Data submitted successfully!');
            },
            error: function(error) {
                console.error('Error submitting data:', error);
            }
        });
    });
});
